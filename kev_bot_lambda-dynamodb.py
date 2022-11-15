import boto3
import requests
import tweepy

def get_old_cves():
    table_name = "KEVs"
    primary_column_name ="i"
    db = boto3.resource('dynamodb')
    table = db.Table(table_name)
    response = table.get_item(
        Key={
            primary_column_name:"0"
        })
        
    old_cve_list = response["Item"]["cves"]
    return old_cve_list

def save_new_cves(cve_list):
    table_name = "KEVs"
    primary_column_name ="i"
    db = boto3.resource('dynamodb')
    table = db.Table(table_name)
    response = table.put_item(
        Item={
            primary_column_name:"0",
            "cves": cve_list
        })
        
    status_code = str(response["ResponseMetadata"]["HTTPStatusCode"])
    return status_code
    
# returns encrypted ssm parameter 
def get_encrypted(key_name):
    client = boto3.client('ssm')
    response = client.get_parameter(Name=key_name, WithDecryption=True)
    testing_param = response['Parameter']['Value']
    return testing_param

def tweet(n_t):
    api_key = get_encrypted('twitter_api_key')
    api_secret = get_encrypted('twitter_api_secret')
    access_token = get_encrypted('twitter_access_token')
    access_secret_token = get_encrypted('twitter_access_secret_token')
    
    # Authenticate 
    auth = tweepy.OAuthHandler(api_key, api_secret)
    auth.set_access_token(access_token, access_secret_token)
    
    #create API Object
    api = tweepy.API(auth)
    
    #Create a tweet
    for message in n_t:
        api.update_status(message)

def lambda_handler(event, context):
    old_cve_list = get_old_cves()
    api_end = "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json"
    kev_dict = requests.get(api_end).json()
    vul_dict = kev_dict['vulnerabilities']
    tweets =[] 
    for key in vul_dict:
        if key['cveID'] not in old_cve_list:
            new_tweet = f"{key['cveID']} - {key['vulnerabilityName']} has been added to the KEV catalog."
            old_cve_list.append(key['cveID'])
            tweets.append(new_tweet)
    if len(tweets) > 0 and len(tweets) < 100:
        tweet(tweets)
        save_new_cves(old_cve_list)
    
    
    return tweets