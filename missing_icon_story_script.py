## Run in root of project

# input
#   - story file for icons
#   - index file for icons
# output
#   - updated the story file with missing icons
story_file_path = 'static/source/react-v2/ImpressLibrary/icons/ImIcons.stories.jsx'
icons_file_path = 'static/source/react-v2/ImpressLibrary/icons/index.js'

new_icons = []
story_icons = []

def get_icon (line):
    return line.split('.')[1].split('=')[0].strip()

def get_story_icon (line):
    return line.split('const')[1].split('=')[0].strip()

with open(story_file_path) as file:
    for line in file:
        line = line.rstrip()
        if not len(line):
            continue
        story_icons.append(get_story_icon(line)) 

with open(icons_file_path) as file:
    for line in file:
        icon = get_icon(line.rstrip())
        if icon in story_icons :
            continue
        new_icons.append('\nexport const {} = () => <ImIcons name="{}" />'.format(icon,icon))

with open('stori.jsx','a') as file:
    for icon in new_icons:
        file.write(icon)