import boto3
from datetime import datetime
import json

dynamodb = boto3.resource('dynamodb', region_name='ap-southeast-1')
table = dynamodb.Table('rooms')

def lambda_handler(event, context):
    day = event['queryStringParameters']['day'].upper()
    time = event['queryStringParameters']['time']

    response = table.scan()
    rooms = response['Items']

    available_rooms = []
    upcoming_rooms = []

    for room in rooms:
        room_number = room['room_number']
        vacant_slots = room['vacant_slots'].get(day, [])

        for slot in vacant_slots:
            if is_time_in_range(slot['start_time'], slot['end_time'], time):
                fmt = '%I:%M %p'
                current_dt = datetime.strptime(time, fmt)
                end_dt = datetime.strptime(slot['end_time'], fmt)
                diff = end_dt - current_dt
                hours, remainder = divmod(diff.seconds, 3600)
                minutes = remainder // 60
                available_rooms.append({
                    'room': room_number,
                    'vacant_until': slot['end_time'],
                    'vacant_for': f'{hours}h {minutes}m',
                    'schedule': vacant_slots
                })
                break
            else:
                fmt = '%I:%M %p'
                current_dt = datetime.strptime(time, fmt)
                slot_start_dt = datetime.strptime(slot['start_time'], fmt)
                if slot_start_dt > current_dt:
                    diff = slot_start_dt - current_dt
                    hours, remainder = divmod(diff.seconds, 3600)
                    minutes = remainder // 60
                    upcoming_rooms.append({
                        'room': room_number,
                        'vacant_in': f'{hours}h {minutes}m',
                        'at': slot['start_time'],
                        'schedule': vacant_slots
                    })
                    break

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'available_now': available_rooms,
            'available_soon': upcoming_rooms,
            'all_rooms': [
                {
                    'room': room['room_number'],
                    'schedule': room['vacant_slots'].get(day, [])
                } for room in rooms
            ]
        })
    }

def is_time_in_range(start, end, current):
    fmt = '%I:%M %p'
    start_dt = datetime.strptime(start, fmt)
    end_dt = datetime.strptime(end, fmt)
    current_dt = datetime.strptime(current, fmt)
    return start_dt <= current_dt <= end_dt


if __name__ == '__main__':
    now = datetime.now()
    current_day = now.strftime('%A').upper()
    current_time = now.strftime('%I:%M %p')

    event = {
        'queryStringParameters': {
            'day': current_day,
            'time': current_time
        }
    }
    print(f"Querying for {current_day} at {current_time}")
    print(lambda_handler(event, None))