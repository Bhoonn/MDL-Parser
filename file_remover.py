# This is your desktop
# Edit in the user
Path = "C:/Users/YourUser/Desktop/"

Files = [
    # Put in the materials printed out in console here
    # You have to have the Path + because it requires the absolute location of the file
    Path + "content_one/materials/models/something/something",
]

import os
for x in Files:
    if os.path.exists(x + ".vtf"):
        os.remove(x + ".vtf")
    if os.path.exists(x + ".vmt"):
        os.remove(x + ".vmt")