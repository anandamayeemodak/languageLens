import cv2
import pytesseract
from googletrans import Translator, constants
import csv;
from pprint import pprint
from gtts import gTTS 
from playsound import playsound 

lang_rows = []

with open("googletrans_lang_codes.csv",'r') as codesfiles:
    csvreader = csv.reader(codesfiles)
    #skipping the first row as it is header
    next(csvreader)
    for row in csvreader:
        lang_rows.append(row)

pytesseract.pytesseract.tesseract_cmd = 'C:\\Program Files\\Tesseract-OCR\\tesseract.exe'
imgPath = 'german1.png'
img = cv2.imread(imgPath)

#pytesseract only accepts RGB values
#opencv images are in BGR
#hence converting
img = cv2.cvtColor(img,cv2.COLOR_BGR2RGB)

#reading from image, storing String in variable 'text'
text = pytesseract.image_to_string(img)
print(text)

#Creating instance of Translator
translator = Translator()  

#detecting src language
src_lang_code = translator.detect(text).lang
src_lang = ""
for i in range(len(lang_rows)):
    if(src_lang_code==lang_rows[i][1]):
        src_lang = lang_rows[i][0]

print(src_lang)

#accepting dest language from user
dest_lang = input("Enter Destination Language: ")
dest_lang_code="de"
#capitalizing first letter
dest_lang = dest_lang.title()
for i in range(len(lang_rows)):
    if(dest_lang==lang_rows[i][0]):
        dest_lang_code = lang_rows[i][1]

#translating
translation = translator.translate(text, dest=dest_lang_code,src=src_lang_code)
print(translation.text)


# sentences = [
#     "Hello everyone",
#     "How are you ?",
#     "Do you speak english ?",
#     "Good bye!"
# ]
# translations = translator.translate(sentences, dest="tr")
# for translation in translations:
#     print(translation.text)

src_var = gTTS(text = text,lang =src_lang_code) 
src_var.save(src_lang_code+"1.mp3")

dest_var = gTTS(text=translation.text,lang=dest_lang_code)
dest_var.save(dest_lang_code+"1.mp3")

