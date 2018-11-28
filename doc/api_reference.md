# API Reference

## Authentication

### Token authentication

```sh
curl -H "Authorization: token [TOKEN]" https://todos-actioncable.herokuapp.com
```

## Pagination

Requests that return multiple items will be paginated to 10 items by default. You can specify further pages with `?page` parameter. You can also set a page size up to 100 the `?per_page` parameter.

```javascript
// curl https://todos-actioncable.heroku.com/api/v1/logs?page=2&per_page=100
{
  "results": [
    // items
  ],
  "links": {
    "first": "https://todos-actioncable.heroku.com/api/v1/logs?page=1&per_page=100",
    "prev": "https://todos-actioncable.heroku.com/api/v1/logs?page=1&per_page=100",
    "next": "https://todos-actioncable.heroku.com/api/v1/logs?page=3&per_page=100",
    "last": "https://todos-actioncable.heroku.com/api/v1/logs?page=4&per_page=100",
  },
  "page": 2,
  "per_page": 100
}
```

Note that page number is 1-based and that omitting the `?page` parameter will return the first page.
