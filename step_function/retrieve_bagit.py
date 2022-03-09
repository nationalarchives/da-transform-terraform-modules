import urllib3
http = urllib3.PoolManager()

def lambda_handler(event, context):
    # TODO implement    
    url = event['s3-bagit-url']
    r = http.request('GET', url)
    print(r)
    data = r.data
    print(type(data))
    
    print(event['s3-bagit-url'])

