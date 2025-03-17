import boto3
import json
from datetime import datetime
import os

def lambda_handler(event, context):
    ssm = boto3.client('ssm')
    instance_id = event['instance-id']

    # Get instance information to retrieve the Name tag
    try:
        instance_info = ssm.describe_instance_information(
            Filters=[
                {
                    'Key': 'InstanceIds',
                    'Values': [instance_id]
                }
            ]
        )
        
        # Get the Name tag from instance information
        if instance_info['InstanceInformationList']:
            instance_name = instance_info['InstanceInformationList'][0].get('Name')
            
            # Add ENV tag with the Name value
            if instance_name:
                ssm.add_tags_to_resource(
                    ResourceType='ManagedInstance',
                    ResourceId=instance_id,
                    Tags=[
                        {
                            "Key": "ENV",
                            "Value": instance_name
                        },
                    ]    
                )
    except Exception as e:
        print(f"Error processing instance {instance_id}: {e}")

    # Send command to the instance
    response = ssm.send_command(
        InstanceIds=[instance_id],
        DocumentName=os.environ.get('RPiInstall')
    )
   
    serializable_response = json.dumps(response, default=str)
    return json.loads(serializable_response)