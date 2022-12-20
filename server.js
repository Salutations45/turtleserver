

const express = require('express');
const bodyParser = require('body-parser')
const app = express();
app.use(bodyParser.text({type: '*/*'}));
const fs = require('fs');

const progs = new Map();
const HIDE_POLL = process.env.HIDE_POLL;
const FILE_PATH = './code/prog.lua';

const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout,
    prompt: '>'
});

let selected = 0;

readline.on('SIGINT', () => {
	process.exit();	
});

readline.on('line', (input)=>{
	try {
		const txt = input.trim();

		if(txt.length===0) {
			//nothing
		}else if(txt.startsWith('SELECT ')) {
			selected = txt.split(' ')[1];
			if(selected) {
				console.log('Selected '+selected);
			}else{
				console.log('Error selecting');
				selected = 0;
			}
		}else if(txt.startsWith('LOADFILE')) {
			if(selected) {
				console.log('Loading file '+FILE_PATH);
				fs.readFile(FILE_PATH , (err, data)=>{
					if(err) {
						console.log(err);
					}else{
						progs.set(selected, data.toString('utf-8'));
						console.log('Loaded program for '+selected);
					}
				});		
			}else{
				console.log('No turtle selected');
			}
		}else{
			if(selected) {
				let prog = progs.get(selected);
				if(!prog) {
					prog = '';
				}
				prog += '\n'+txt;
				progs.set(selected, prog);
				console.log(selected + ' > ' + txt);
			}else{
				console.log('No turtle selected');
			}
		}		
	}catch(e) {
		console.log('Error ', e);
	}
	readline.prompt();
});

const PORT = process.env.LISTEN_PORT
app.listen(PORT, ()=>{
	console.log('Listening on port '+PORT);
	readline.prompt();
});

app.get('/prog/:key', (req, res, next)=>{
	const prog = progs.get(req.params.key);
	if(prog) {
		console.log('Sending program to '+ req.params.key);
		res.send(prog);
		progs.delete(req.params.key);
	}else{
		if(!HIDE_POLL) {
			console.log('No prog for key '+ req.params.key);
		}
		res.status(404).send();
	}
});

app.post('/return/:key', (req, res, next)=>{
	console.log('Prog return by '+ req.params.key);
	console.log(req.body);
	res.status(200).send()
});

app.post('/event/:key', (req, res, next)=>{
	console.log('Event by '+ req.params.key);
	console.log(req.body);
	res.status(200).send()
});
