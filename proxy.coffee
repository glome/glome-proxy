http = require('http')
https = require('https')
config = require('./config.json')

# If the current 
if config.proxy.ssl
  serverType = https
else
  serverType = http

serializedParams = "application[apikey]=#{config.application.apikey}&application[uid]=#{config.application.uid}"

# Headers that should be passed through
disallowHeaders = ['host', 'content-length']

inArray = (needle, haystack) ->
  for i in [0...haystack.length]
    if haystack[i] is needle
      return true
  return false

# Create a HTTP server to listen for incoming requests
server = serverType.createServer (req, res) ->
  console.log 'Request received', req.method, req.url
  data = ''
  headers = {}
  
  url = req.url
  
  # Append URL parameters on GET
  if req.method is 'GET'
    if url.match(/\?/)
      url += '&'
    else
      url += '?'
    url += serializedParams
  
  # Copy the request headers
  for k, v of req.headers
    if inArray k, disallowHeaders
      continue
    headers[k] = v
  
  # Proxy request options
  options =
    host: config.api.host
    path: url
    port: config.api.port
    method: req.method
    headers: headers
  
  req.on 'data', (chunk) ->
    data += chunk
    return
    
  req.on 'end', ->
    if req.method isnt 'GET' and req.method isnt 'DELETE'
      if data
        data += "&#{serializedParams}"
      else
        data = serializedParams
    
    # Response for the recipient
    if config.api.ssl
      https.request(options, callback).end()
    else
      http.request(options, callback).end()
  
  # HTTP request callback
  callback = (proxyReq, proxyRes) ->
    res.statusCode = proxyReq.statusCode
    
    proxyData = ''
    
    # Start passing through the request
    proxyReq.on 'data', (chunk) ->
      proxyData += chunk
    
    proxyReq.on 'end', ->
      for k, v of proxyReq.headers
        res.setHeader k, v
      res.writeHead proxyReq.statusCode
      res.end(proxyData)
    
server.listen config.proxy.port
console.log 'This server listens to port', config.proxy.port