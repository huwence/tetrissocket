fs = require('fs')
path = require('path')
url = require('url')

handler = (request, response) ->
    pathname = 'public' + url.parse(request.url).pathname
    contenttype = ''

    console.log pathname

    if path.extname(pathname) == ''
        pathname += '/'

    fs.exists(pathname, (exists) ->
        if not exists
            response.writeHead(404)
            return response.end('404')

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
app.listen process.env.PORT || 8080
io = require('socket.io').listen(app)

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
