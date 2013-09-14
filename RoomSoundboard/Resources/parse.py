import re

room = open("room.html", "r")
personPattern = '(.*)<h2><img src=\"(.*)'
soundPattern = '(.*)<li><a href=\"#\" id=\"(.*)'

dictionary = ""
dictionary += "[\n"

firstPerson = True
firstSound = True

for line in room:
	personLine = re.match(personPattern, line)
	soundLine = re.match(soundPattern, line)
	if personLine is not None:
		line = line.replace('<h2><img src=\"', "")
		splitline = line.split("\"")
		person = splitline[2]
		image = splitline[0].strip()
		# Close previous dictionary if necessary.
		if firstPerson is False:
			dictionary += "]\n},\n"
		firstPerson = False
		dictionary += "	{\n"
		dictionary += "		\"person\" : \"" + person + "\",\n"
		dictionary += "		\"image\" : \"" + image + "\",\n"
		firstSound = True
	elif soundLine is not None:
		line = line.replace('      <li><a href=\"#\" id=\"', "")
		line = line.replace('</a></li>', "")
		line = line.replace('>', "")
		splitline = line.split("\"")
		sound = "http://assets1.theroomsoundboard.com/" + splitline[0] + ".mp3"
		title = splitline[1]
		if firstSound:
			dictionary += "		\"sounds\" : ["
		else:
			dictionary += ","
		firstSound = False
		dictionary +=  "{\"sound\" : \"" + sound + "\", \"title\" : \"" + title + "\"" + "}"
dictionary += "	]}\n]"

dictionary = dictionary.replace('\n', '')
soundsFile = open('roomsounds.json', 'w')
soundsFile.write(dictionary)