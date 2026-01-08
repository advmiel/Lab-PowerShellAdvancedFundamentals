$uri = "https://jsonplaceholder.typicode.com/posts"

Invoke-RestMethod -Method Get -Uri $uri

# Get specific resource from posts:
$urispecific = $uri + "?id=101"

Invoke-RestMethod -Method Get -Uri $urispecific

Invoke-WebRequest -Uri $urispecific -Method Get -UseBasicParsing

$myobj = [psobject]@{
    title = "yo"
    body = "my first post"
    userId = 1
}
$myobjjson = $myobj | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method Post -Body $myobjjson -ContentType "application/json"

$bodyesc = $($myobj.body) -replace " ","%20"

# Get my post
$urispecific = $uri + "?title=$($myobj.title)&body=$bodyesc&userId=$($myobj.userId)&id=$($myobj.id)"

Invoke-RestMethod -Method Get -Uri $urispecific

Invoke-RestMethod -Uri $uri -Method Get