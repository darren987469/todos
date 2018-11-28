# API Reference

## Authentication

### Token authentication

```sh
curl -H "Authorization: token [TOKEN]" https://todos-actioncable.herokuapp.com
```

## Pagination

Requests that return multiple items will be paginated to 10 items by default. You can specify further pages with `?page` parameter. You can also set a page size up to 100 the `?per_page` parameter.

```javascript
// curl https://todos-actioncable.herokuapp.com/api/v1/todo_lists/1/logs?page=2&per_page=100
{
  "results": [
    // items
  ],
  "links": {
    "first": "https://todos-actioncable.herokuapp.com/api/v1/todo_lists/1/logs?page=1&per_page=100",
    "prev": "https://todos-actioncable.herokuapp.com/api/v1/todo_lists/1/logs?page=1&per_page=100",
    "next": "https://todos-actioncable.herokuapp.com/api/v1/todo_lists/1/logs?page=3&per_page=100",
    "last": "https://todos-actioncable.herokuapp.com/api/v1/todo_lists/1/logs?page=4&per_page=100",
  },
  "page": 2,
  "per_page": 100
}
```

Note that page number is 1-based and that omitting the `?page` parameter will return the first page.

## Rate limiting

For API requests using token, you can make up to 5000 requests per hour. Authenticated requests are associated with the authenticated user. This means that all applications authorized by a user share the same quota of 5000 requests per hour when they authenticate with different tokens owned by the same user.

The returned HTTP header of any API request show you current rate limit status:

```sh
curl -i https://todos-actioncable.herokuapp.com/api/v1/todo_lists/1/logs
HTTP/1.1 200 OK
X-RateLimit-Limit: 5000
X-RateLimit-Remaining: 4998
X-RateLimit-Reset: 1543396712
```

Header Name | Description
------------|-------------
`X-RateLimit-Limit` | The maximum number of requests you're permitted to make per hour.
`X-RateLimit-Remaining` | The number of requests remaining in the current rate limit window.
`X-RateLimit-Reset` | The time at which the current rate limit window resets in UTC epoch seconds.
