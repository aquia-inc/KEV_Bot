import boto3
import tweepy
import requests

# returns previously saved total number of KEVs
def get_saved():
    client = boto3.client('ssm')
    response = client.get_parameter(Name='totalResults')
    return response['Parameter']['Value']

# returns encrypted ssm parameter 
def get_encrypted(key_name):
    client = boto3.client('ssm')
    response = client.get_parameter(Name=key_name, WithDecryption=True)
    testing_param = response['Parameter']['Value']
    return testing_param

# Saves total number of KEVs to ssm parameter
def save(t_r):
    client = boto3.client('ssm')
    response = client.put_parameter(Name='totalResults', Value=str(t_r), Type='String', Overwrite=True)
    
def tweet_messages(message_list):
    api_key = get_encrypted('twitter_api_key')
    api_secret = get_encrypted('twitter_api_secret')
    access_token = get_encrypted('twitter_access_token')
    access_secret_token = get_encrypted('twitter_access_secret_token')
    
    # Authenticate 
    auth = tweepy.OAuthHandler(api_key, api_secret)
    auth.set_access_token(access_token, access_secret_token)
    
    #create API Object
    api = tweepy.API(auth)
    
    #Create a tweets
    for message in message_list:
        api.update_status(message)

# Returns list of formated messages to tweet    
def make_tweet_list(k_d):
    vuln_dict = k_d['vulnerabilities']
    tweets =[]
    for key in vuln_dict:
        tweets.append(f"{key['cve']['id']} - {key['cve']['cisaVulnerabilityName']} has been added to the KEV catalog")
    return tweets    
    
def lambda_handler(event, context):
    # Main Function
    stored_results = get_saved()
    api_end = f"https://services.nvd.nist.gov/rest/json/cves/2.0?hasKev&startIndex={stored_results}"
    kev_dict = requests.get(api_end).json()
    if kev_dict['resultsPerPage'] > 0:
        tweet_list = make_tweet_list(kev_dict)
        tweet_messages(tweet_list)
        save(kev_dict['totalResults'])
        return tweet_list
    
    return stored_results
