'use strict'

const Helper = require('../src/index');
const helper = new Helper('./scripts/give-json.js');

const co = require('co');
const expect = require('chai').expect;

describe('json message test', function () {
  beforeEach(function () {
    this.room = helper.createRoom({ httpd: false });
  });
  afterEach(function () {
    this.room.destroy();
  });

  context('user asks hubot for json', function () {

    it('should reply to user', async function () {
      await this.room.user.say('alice', '@hubot send json');
      expect(this.room.messages).to.eql([
        ['alice', '@hubot send json'],
        ['hubot', { text: 'one json for you', someNumber: 2 }]
      ]);
    });
  });
});
