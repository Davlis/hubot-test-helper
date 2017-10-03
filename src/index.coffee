Fs    = require('fs')
Path  = require('path')
Hubot = require('hubot')

process.setMaxListeners(0)

class MockResponse extends Hubot.Response
  sendPrivate: (strings...) ->
    @robot.adapter.sendPrivate @envelope, strings...

class MockRobot extends Hubot.Robot
  constructor: (httpd=true) ->
    super null, null, httpd, 'hubot'

    @Response = MockResponse

  loadAdapter: ->
    @adapter = new Room(@)

class Room extends Hubot.Adapter
  constructor: (@robot) ->
    @messages = []

    @privateMessages = {}

    @user =
      say: (userName, message, userParams) =>
        @receive(userName, message, userParams)

      enter: (userName, userParams) =>
        @enter(userName, userParams)

      leave: (userName, userParams) =>
        @leave(userName, userParams)

  receive: (userName, message, userParams = {}) ->
    new Promise (resolve) =>
      textMessage = null
      if typeof message is 'object' and message
        textMessage = message
      else
        userParams.room = @name
        user = new Hubot.User(userName, userParams)
        textMessage = new Hubot.TextMessage(user, message)

      @messages.push [userName, textMessage.text]
      @robot.receive(textMessage, resolve)

  destroy: ->
    @robot.server.close() if @robot.server

  reply: (envelope, strings...) ->
    @messages.push ['hubot', "@#{envelope.user.name} #{str}"] for str in strings

  send: (envelope, strings...) ->
    @messages.push ['hubot', str] for str in strings

  sendPrivate: (envelope, strings...) ->
    if envelope.user.name not of @privateMessages
      @privateMessages[envelope.user.name] = []
    @privateMessages[envelope.user.name].push ['hubot', str] for str in strings

  robotEvent: () ->
    @robot.emit.apply(@robot, arguments)

  enter: (userName, userParams = {}) ->
    new Promise (resolve) =>
      userParams.room = @name
      user = new Hubot.User(userName, userParams)
      @robot.receive(new Hubot.EnterMessage(user), resolve)

  leave: (userName, userParams = {}) ->
    new Promise (resolve) =>
      userParams.room = @name
      user = new Hubot.User(userName, userParams)
      @robot.receive(new Hubot.LeaveMessage(user), resolve)

class Helper
  @Response = MockResponse

  constructor: (scriptsPaths) ->
    if not Array.isArray(scriptsPaths)
      scriptsPaths = [scriptsPaths]
    @scriptsPaths = scriptsPaths

  createRoom: (options={}) ->
    robot = new MockRobot(options.httpd)

    if 'response' of options
      robot.Response = options.response

    for script in @scriptsPaths
      script = Path.resolve(Path.dirname(module.parent.filename), script)
      if Fs.statSync(script).isDirectory()
        for file in Fs.readdirSync(script).sort()
          robot.loadFile script, file
      else
        robot.loadFile Path.dirname(script), Path.basename(script)

    robot.brain.emit 'loaded'

    robot.adapter.name = options.name or 'room1'
    robot.adapter

module.exports = Helper
