'use strict'

const Helper = require('../src/index');
const helper = new Helper('./scripts/give-json.js');

const co = require('co');
const expect = require('chai').expect;

describe('json message text', function () {
  beforeEach(function () {
    this.room = helper.createRoom({ name: 'room', httpd: false });
  });

  context('user asks hubot for json', function () {
    beforeEach(function () {
      return co(function* () {
        yield this.room.user.say('alice', '@hubot send json');
      }.bind(this));
    });

    it('should reply to user with json', function () {
      expect(this.room.messages).to.eql([
        ['alice', '@hubot send json'],
        ['hubot', { text: 'one json for you', someNumber: 2 }]
      ]);
    });

  });
});
