# How to authenticate with token

## Step1: Generate token

1. Login account then click `Settings`.
1. Fill the description of the token, select token scopes, then generate the token.
1. Copy the token for future API call use.

![](images/generate_token.png)

## Step2: Authenticate user with token to call API

### API doc

1. Go to API doc.
    * Production:  https://todos-actioncable.herokuapp.com/swagger
    * Development: http://localhost:3000/swagger
2. Fill the token with the format `token [YOUR TOKEN]`.
3. Try API call!

![](images/authenticate_with_token.png)

### curl

```sh
curl --header 'Authorization: token [YOUR TOKEN]' https://todos-actioncable.herokuapp.com/api/v1/rate_limit
```
