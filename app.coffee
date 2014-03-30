fs = require('fs')
path = require('path')
url = require('url')

handler = (request, response) ->
    pathname = __dirname + url.parse(request.url).pathname
    contenttype = ''

    if path.extname(pathname) == ''
        pathname += '/'

    fs.exists(pathname, (exists) ->
        response.writeHead(404) if not exists

        ext = path.extname(pathname)

        contenttype = switch
            when ext is ".html" then {"Content-Type": "text/html"}
            when ext is ".js" then {"Content-Type": "text/javascript"}
            when ext is ".css" then {"Content-Type": "text/css"}
            when ext is ".jpg" then {"Content-Type": "text/jpg"}
            when ext is ".png" then {"Content-Type": "text/png"}
            else {"Content-Type": "application/octet-stream"}
    )

    fs.readFile(pathname, (error, data) ->
        if error
            response.writeHead(500)
            return response.end('Error loading')

        response.writeHead(contenttype)
        response.end(data)
    )



app = require('http').createServer(handler)
io = require('socket.io').listen(app)
app.listen 8081

#io.sockets.on('connection', (socket) ->
#    socket.emit('news', {task: '[1, 0]'})
#    socket.on('got it', (data) ->
#        console.log(data)
#    )
#)

io.sockets.on('connection', (socket) ->
    players = 0

    socket.on('move', (data) ->
        io.sockets.emit 'do', data
    )

    socket.on('enter', (data) ->
        waiting = 1

        console.log(data)
        console.log(players)
        if players is 0 and data
            waiting = 0
            io.sockets.emit('start', 1)

        io.sockets.emit('waiting', waiting)
        ++ players
    )

    socket.on('disconnect', () ->
        -- players
    )
)
