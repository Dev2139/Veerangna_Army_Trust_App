const mongoose = require('mongoose');
const Event = require('./models/Event');
const dotenv = require('dotenv');

dotenv.config();

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/army_donation').then(async () => {
  const events = await Event.find();
  console.log(JSON.stringify(events, null, 2));
  process.exit(0);
});
