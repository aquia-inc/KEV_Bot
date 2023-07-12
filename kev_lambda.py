import boto3
import requests
import tweepy


def seed_the_table():
    api_end = "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json"
    kev_dict = requests.get(api_end).json()
    vul_dict = kev_dict["vulnerabilities"]
    cve_list = [key["cveID"] for key in vul_dict]
    table_name = "OldKevs"
    primary_column_name = "i"
    db = boto3.resource("dynamodb")
    table = db.Table(table_name)
    response = table.put_item(Item={primary_column_name: "0", "cves": cve_list})

    status_code = str(response["ResponseMetadata"]["HTTPStatusCode"])
    return status_code


def get_old_cves():
    table_name = "OldKevs"
    primary_column_name = "i"
    db = boto3.resource("dynamodb")
    table = db.Table(table_name)
    response = table.get_item(Key={primary_column_name: "0"})

    try:
        old_cve_list = response["Item"]["cves"]
    except KeyError:
        seed_the_table()
        old_cve_list = get_old_cves()
    return old_cve_list


def save_new_cves(cve_list):
    table_name = "OldKevs"
    primary_column_name = "i"
    db = boto3.resource("dynamodb")
    table = db.Table(table_name)
    response = table.put_item(Item={primary_column_name: "0", "cves": cve_list})

    status_code = str(response["ResponseMetadata"]["HTTPStatusCode"])
    return status_code


def tweet(n_t):
    api_key = get_encrypted("twitter_api_key_iac")
    api_secret = get_encrypted("twitter_api_secret_iac")
    access_token = get_encrypted("twitter_access_token_iac")
    access_secret_token = get_encrypted("twitter_access_secret_token_iac")

    # Authenticate
    auth = tweepy.OAuth1UserHandler(
        api_key, api_secret, access_token, access_secret_token
    )
    # create API Object
    api = tweepy.API(auth)

    # Create a tweet
    for message in n_t:
        api.update_status(message)


def get_encrypted(key_name):
    client = boto3.client("ssm")
    response = client.get_parameter(Name=key_name, WithDecryption=True)
    testing_param = response["Parameter"]["Value"]
    return testing_param


def lambda_handler(event, context):
    old_cve_list = get_old_cves()
    api_end = "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json"
    kev_dict = requests.get(api_end).json()
    vul_dict = kev_dict["vulnerabilities"]
    tweets = []
    for key in vul_dict:
        if key["cveID"] not in old_cve_list:
            new_tweet = f"{key['cveID']} - {key['vulnerabilityName']} has been added to the KEV catalog.  https://nvd.nist.gov/vuln/detail/{key['cveID']}"
            old_cve_list.append(key["cveID"])
            tweets.append(new_tweet)
    if len(tweets) > 0 and len(tweets) < 100:
        # tweet(tweets)
        save_new_cves(old_cve_list)
        post_to_slack(tweets)

    return tweets


def post_to_slack(tweets):
    """Posts to slack

    Args:
        tweets ([list]): Tweets to post to slack
    """

    url = get_encrypted("slack_webhook_url")

    for tweet in tweets:
        payload = {
            "text": "Alert!! ",
            "attachments": [
                {
                    "blocks": [
                        {
                            "type": "section",
                            "text": {"type": "plain_text", "text": tweet},
                        }
                    ]
                }
            ],
        }
        # Post to the slack channel
        try:
            requests.post(url, json=payload)
            print("Posting to Slack")
        except Exception as e:
            print(e)
            raise
