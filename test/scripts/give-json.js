// Description:
//   Test script
module.exports = robot => {
  robot.respond(/send json/, res => {
    return res.send({ text: 'one json for you', someNumber: 2 });
  });

  robot.respond(/send other json/, res => {
    return res.send({ someNumber: 2 });
  });
};
