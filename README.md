# MDL-Parser
This tool is used for getting all of the materials inside of a single folder that models (mdl files) do not require
It works by getting all of the materials in that folder caching them, then it will go and grab all the materials all mdl files require
After this the system will look and see which materials are left over that those mdl files dont need
It will print them out in console, now you can use any script outside of lua to remove all of those materials
Or you can manually remove every single material printed out yourself

-- WARNING --
Any icons or materials that are not related to a model, they will be printed out aswell
This only works for materials and models related to eachother in this folder
Any models that use the materials in that folder but are outside the folder, will cause those materials to be printed out (for removal)

Before use:

MAKE SURE TO CREATE A BACKUP FOR THE CONTENT FOLDER
IT IS NOT YET TESTED IN ANY LARGE SCALE AND COULD BE BROKEN
