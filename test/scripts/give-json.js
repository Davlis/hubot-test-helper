// Description:
//   Test script
module.exports = robot => {
  robot.respond(/send json/, res => {
    return res.send({ text: 'one json for you', someNumber: 2 });
  });
};
