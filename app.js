// Import required modules
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser'); // Import body-parser
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken'); // Import jsonwebtoken library
const cors = require('cors'); // Import the cors middleware



// Create an Express app
const app = express();
const path = require('path');

// Use the cors middleware
app.use(cors({
//    origin: 'http://127.0.0.1:3000' I'm having some trouble with CORS so let's try disabling this line
}));

app.use('/protected', authenticateToken, (req, res) => {
  res.json({ message: 'You have accessed a protected route!' });
});

function authenticateToken(req, res, next) {
  // Get the token from the request headers
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer <Token>

  if (!token) return res.status(401).json({ message: 'Token not provided' });

  // Verify the token
  jwt.verify(token, 'your-secret-key', (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid Token' });
    req.user = user; // Store user info in the request object
    next(); // Move to the next middleware or route handler
  });
}

async function isAdmin(req, res, next) {
    try {
        const userId = req.user.userId;
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        req.user.isAdmin = user.role === "admin";
//        console.log(req.user.isAdmin);

        next(); // proceed to the next middleware/route handler
    } catch (error) {
//        console.log(error);
        return res.status(500).json({ message: 'Server error' });
    }
}




app.use(express.static(path.join(__dirname, '/')));

app.use(bodyParser.json()); // Parse JSON requests

// Set up MongoDB connection
mongoose.connect('mongodb+srv://talmagesharp321:Ihateps4@nebulacluster.9d57wlp.mongodb.net/?retryWrites=true&w=majority', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const db = mongoose.connection;
db.on('error', console.error.bind(console, 'MongoDB connection error:'));
db.once('open', () => {
  console.log('Connected to MongoDB');
});

const User = mongoose.model('User', {
 username: String,
 password: String,
 email: String,
 role: String,
 rank: String,
 profilePicture: String,
});

const SquatSchema = new mongoose.Schema({
  owner: {
      type: mongoose.Schema.Types.ObjectId, // Use ObjectId data type from mongoose
      ref: 'User', // This should match the name of your User model
      required: false // This enforces that every squat must have an owner
    },
  name: String,
  location: String,
  likes: {
      type: Number,
      default: 0 // It's good to have a default value for likes
    },
  image: String,
  coordinates: {
    type: {
      type: String,
      enum: ['Point'], // 'location.type' must be 'Point'
//      default: 'Point' // Default can be set if you always want it to be 'Point'
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      index: '2dsphere',
       required: false// You can define the index here for geospatial queries
    }
  }
});

// Alternatively, you can set the index like this, outside the schema definition
// SquatSchema.index({ 'coordinates.coordinates': '2dsphere' });

const Squat = mongoose.model('Squat', SquatSchema);


app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '/', 'build/web/index.html'));
});

app.post('/new_squat', authenticateToken, async(req, res) => {
    const { name, location, image, likes, coordinates } = req.body;
    const ownerId = req.user.userId; // Assuming the user ID is available on req.user._id

    const newSquat = new Squat({
        owner: ownerId,
        name,
        location,
        image,
        likes,
        coordinates // Add this line to include coordinates
    });

    try {
        await newSquat.save();
        res.status(201).json({ message: 'Squat created successfully' });
    } catch (error) {
        // Handle any errors that occur during the save
        console.error('Error creating squat:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});


app.get('/user-data', authenticateToken, async (req, res) => {
    try {
    const userId = req.user.userId;

    const user = await User.findById(userId);

    if(!user){
        return res.status(404).json({ message: 'User not found'});
    }

    return res.json({email: user.email, username: user.username, rank: user.rank, profilePicture: user.profilePicture });
    } catch (error) {
        return res.status(500).json({ message: 'server error'});
    }
});

app.post('/update-squat', authenticateToken, async (req, res) => {
    try {
//        console.log("received an update request");
        const squatId = req.body.squatId; // Assuming you pass the squat's ID in the request body.
        // Extract data from request body
        const { name, location, likes, image, coordinates } = req.body;
        const squat = await Squat.findById(squatId);
        if (!squat) {
            return res.status(404).json({ message: 'Squat not found' });
        }
        if(squat.ownerId != req.user.id){
            return res.status(403).json({message: 'You are not the owner of this squat'});
        }
        // Update squat's details
        if (name) {
            squat.name = name;
        }
        if (location) {
            squat.location = location;
        }
        if (likes) {
            squat.likes = likes; // Note: This directly sets the likes. You might want to increment instead, depending on your use case.
        }
        if (image) {
            squat.image = image;
        }
        if (coordinates) {
            // Assuming you're passing coordinates as an object like: { type: 'Point', coordinates: [longitude, latitude] }
            squat.coordinates = coordinates;
        }
        await squat.save(); // Save changes to the database
        return res.json({ message: 'Squat data updated successfully' });

    } catch (error) {
        console.error('Error updating squat:', error);
        return res.status(500).json({ message: error.message });
    }
});

app.delete('/squats/:id', authenticateToken, async (req, res) => {
  const squatId = req.params.id;
  const userId = req.user.userId; // Assuming you have the user's ID from the token

  try {
    const squat = await Squat.findById(squatId);

    if (!squat) {
      return res.status(404).json({ error: 'Squat not found' });
    }

    const isOwner = squat.owner.toString() === userId;
    const isAdmin = req.user.isAdmin; // Assuming you have an isAdmin flag in your user object

    if (!isAdmin && !isOwner) {
      return res.status(403).json({ error: 'Not authorized to delete this squat' });
    }

    await Squat.findByIdAndDelete(squatId);
    res.status(200).json({ message: 'Squat deleted successfully' });
  } catch (error) {
    console.error('Error deleting squat:', error);
    res.status(500).json({ error: 'Error deleting squat' });
  }
});



app.post('/update-user', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        // Extract data from request body
        const { email, username, profilePicture} = req.body;
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        // Update user's details
        if (email) {
            user.email = email;
        }
        if (username) {
            user.username = username;
        }
        if (profilePicture) {
            user.profilePicture = profilePicture;
        }
        await user.save(); // Save changes to the database
        return res.json({ message: 'User data updated successfully' });
    } catch (error) {
        console.error('Error updating user:', error);
        return res.status(500).json({ message: 'server error' });
    }
});

app.get('/check_username/:username', async (req, res) => {
  const { username } = req.params;
  const user = await db.collection('users').findOne({ username });
  if (user) {
   console.log("username is taken");
    res.status(409).send('taken');
  } else {
  console.log("username: " + username + " is available");
    res.status(200).send('available');
  }
});

app.get('/check_email/:email', async (req, res) => {
  const { email } = req.params;
  const user = await db.collection('users').findOne({ email });
  if (user) {
    console.log("email is taken");
    res.status(409).send('taken');
  } else {
    console.log("email is not taken");
    res.status(200).send('available');
  }
});

app.get('/squats', authenticateToken, isAdmin, async (req, res) => {
  try {
    const squats = await Squat.find().lean();
    console.log('Authenticated User ID:', req.user.userId);
    console.log('Is Admin:', req.user.isAdmin);

    const squatsWithOwnership = squats.map(squat => {
      console.log('Squat Owner:', squat.owner);
      var isOwner = squat.owner ? req.user.userId === squat.owner.toString() : false;
      console.log('Is Owner:', isOwner);
      if(!isOwner && req.user.isAdmin){
        isOwner = req.user.isAdmin;
      }
      return { ...squat, isOwner };
    });

    console.log('Squats with Ownership:', squatsWithOwnership);
    res.json(squatsWithOwnership);
  } catch (error) {
    console.error('Error fetching squats:', error);
    res.status(500).json({ error: 'Error fetching squats' });
  }
});


app.post('/register', async (req, res) => {
//  console.log('attempting to post the username and password');
//  console.log(req);
  const { username, email, password,  } = req.body;
  // Hash the password before saving it
  const hashedPassword = await bcrypt.hash(password, 10);
  // Create a new user record in the database
  const newUser = new User({ username, email, password: hashedPassword, rank: 'Tenderfoot', role: 'user' });
  await newUser.save();
  res.status(201).json({ message: 'User registered successfully' });
});

app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  // Fetch user data from the database based on the provided username
  const user = await User.findOne({ username });

  if (!user) {
    return res.status(401).json({ message: 'No User Found' });
  }

  // Compare the provided password with the hashed password in the database
  const passwordMatch = await bcrypt.compare(password, user.password);

  if (!passwordMatch) {
    return res.status(401).json({ message: 'Invalid password' });
  }

  // Generate a JWT token
  const token = jwt.sign({ userId: user._id }, 'your-secret-key', {expiresIn: '2 weeks'});

  res.status(200).json({ message: 'Login successful', token });
//  console.log('login successful!');
});
// Set up your routes and middleware
// ...

// Start the Express server
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});

/* Your Problems:
1. You have no routes for your login and signup in your DB
2. You need to have the login/signup pages use push commands to login
3. You need to use user authentication.
4. you should probably learn how to actually do it and not just have ChatGPT code it all for you hahahah
*/
