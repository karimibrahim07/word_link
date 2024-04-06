const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use('/static', express.static('public'));

app.get('/dictionary', (req, res) => {
    const dictionaryPath = path.join(__dirname, 'dictionary_en.json');

    fs.access(dictionaryPath, fs.constants.F_OK, (err) => {
        if (err) {
            console.error("Dictionary file not found.");
            return res.status(404).send('Dictionary file not found.');
        }
        
        fs.readFile(dictionaryPath, 'utf8', (err, data) => {
            if (err) {
                console.error("Error reading dictionary file:", err);
                return res.status(500).send('Error reading dictionary file.');
            }
            
            res.header("Content-Type", 'application/json');
            res.send(data);
        });
    });
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
