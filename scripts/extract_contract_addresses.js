const fs = require('fs')
const output = {}

const lineReader = require('readline').createInterface({
    input: fs.createReadStream(process.argv[2])
});

lineReader.on('line', line => {
    [label, address] = line.split(",")
    name = label.trim().split(" ")[0]
    output[name] = address.trim()
})

lineReader.on('close', () => {
    console.log(JSON.stringify(output, null, 4))
})
