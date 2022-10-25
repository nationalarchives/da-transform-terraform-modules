#!/usr/bin/env python3
import time
import uuid

MESSAGE_VERSION = '1.0.0'

def create_tdr_message(
        environment: str,
        consignment_type: str,
        consignment_ref: str,
        s3_bagit_url: str,
        s3_sha_url: str,
        message_version: str=MESSAGE_VERSION,
        timestamp: int=int(time.time_ns()),
        uuid_list: list=None
) -> dict:
    if uuid_list is None:
        uuid_list = [
            {
                'TDR-UUID': str(uuid.uuid4())
            }
        ]

    return {
        'version': message_version,
        'timestamp': timestamp,
        'UUIDs': uuid_list,
        'producer': {
            'environment': environment,
            'name': 'TDR',
            'process': 'tdr-export-process',
            'event-name': 'bagit-available',
            'type': consignment_type
        },
        'parameters': {
            'bagit-available': {
                'resource': {
                    'resource-type': 'Object',
                    'access-type': 'url',
                    'value': s3_bagit_url
                },
                'resource-validation': {
                    'resource-type': 'Object',
                    'access-type': 'url',
                    'validation-method': 'SHA256',
                    'value': s3_sha_url
                },
                'number-of-retries': 0,
                'reference': consignment_ref
            }
        }
    }
