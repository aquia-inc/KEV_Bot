import boto3
import requests


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
    messages = []
    for key in vul_dict:
        if key["cveID"] not in old_cve_list:
            new_message = f"{key['cveID']} - {key['vulnerabilityName']} has been added to the KEV catalog.  https://nvd.nist.gov/vuln/detail/{key['cveID']}"
            old_cve_list.append(key["cveID"])
            messages.append(new_message)
    if len(messages) > 0 and len(messages) < 100:
        save_new_cves(old_cve_list)
        post_to_slack(messages)

    return messages


def post_to_slack(messages):
    """Posts to slack

    Args:
        messages ([list]): messages to post to slack
    """

    url = get_encrypted("slack_webhook_url")

    for message in messages:
        payload = {
            "text": "Alert!! ",
            "attachments": [
                {
                    "blocks": [
                        {
                            "type": "section",
                            "text": {"type": "mrkdwn", "text": message},
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
