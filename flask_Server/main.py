#for creating flask server
from flask import Flask,request,jsonify
#for encoding response into JSON format
from flask.json import JSONEncoder;
#Library supporting flask for saving image
import werkzeug;
#for converting BGR image to RGB image
import cv2
#python module for using tesseract from within python
import pytesseract
#for translation
from googletrans import Translator, constants
#for read/write operations on csv files
import csv;
#for TTS
from gtts import gTTS
#for deleting, renaming csv files  
import os
#for web-scraping
import bs4;
import requests;

count = []
statCount = []
lang_rows = []


app = Flask(__name__);
@app.route('/', methods = ['GET','POST'])

def upload():
    if request.method == 'POST':
        count.clear();
        lang_rows.clear();
        imageFile = request.files['image']
        filename = werkzeug.utils.secure_filename(imageFile.filename)
        # print("Hello world!")
        imageFile.save("uploadedimages/"+filename)
        imgpath = "uploadedimages/"+filename
        # print(filename[3:filename.index("dest")])
        src_lang = filename[3:filename.index("dest")]
        dest_lang = filename[filename.index("dest")+4:filename.index("image")]
        readLangCodes()
        readLangCounts()
        original_text = OCRProcess(imgpath,src_lang)
        translated_text, src_lang_code, dest_lang_code = translatorProcess(src_lang,dest_lang,original_text)
        textToSpeechProcess(original_text,translated_text,src_lang_code,dest_lang_code)
        newsArticle = getNews()
        writeLangCounts()
        statLang, statCount = statCounter()
        # print(statLang)
        # print(statCount)

        return jsonify({
            "originalText" : original_text,
            "translatedText": translated_text,
            "newsFlash" : newsArticle,
            "statLang" : statLang,
            "statCount" : statCount

        })
def readLangCodes():
    with open("googletrans_lang_codes.csv",'r') as codesfiles:
        csvreader = csv.reader(codesfiles)
        #skipping the first row as it is header
        next(csvreader)
        for row in csvreader:
            lang_rows.append(row)

def readLangCounts():
    with open("Lang_counts.csv","r") as countfile:
        countreader = csv.reader(countfile)
        #skipping the first row as it is header
        next(countreader)
        for row in countreader:
            count.append(row)
    # print(count)

def OCRProcess(imgPath,src_lang):
    pytesseract.pytesseract.tesseract_cmd = 'C:\\Program Files\\Tesseract-OCR\\tesseract.exe'
    img = cv2.imread(imgPath)
    #pytesseract only accepts RGB values
    #opencv images are in BGR
    #hence converting
    img = cv2.cvtColor(img,cv2.COLOR_BGR2RGB)
    #reading from image, storing String in variable 'text'
    src_lang_code_ocr = "eng"
    for i in range(len(lang_rows)):
        if(src_lang==lang_rows[i][0]):
            src_lang_code_ocr = lang_rows[i][2]

    text = pytesseract.image_to_string(img,lang=src_lang_code_ocr)
    text = text.replace("\n"," ")
    # print(text)
    return text;

def translatorProcess(src_lang,dest_lang,text):
    #Creating instance of Translator
    translator = Translator()  

    #detecting src language
    src_lang_code = ""
    #translator.detect(text).lang

    for i in range(len(lang_rows)):
        if(src_lang==lang_rows[i][0]):
            src_lang_code = lang_rows[i][1]
            count[i][1] = int(count[i][1])+1

    # print(src_lang)

    #capitalizing first letter
    dest_lang = dest_lang.title()
    for i in range(len(lang_rows)):
        if(dest_lang==lang_rows[i][0]):
            dest_lang_code = lang_rows[i][1]
            count[i][1] = int(count[i][1])+1

    #translating
    translation = translator.translate(text, dest=dest_lang_code,src=src_lang_code)
    # print(translation.text)
    return translation.text, src_lang_code, dest_lang_code


    # sentences = [
    #     "Hello everyone",
    #     "How are you ?",
    #     "Do you speak english ?",
    #     "Good bye!"
    # ]
    # translations = translator.translate(sentences, dest="tr")
    # for translation in translations:
    #     print(translation.text)
def textToSpeechProcess(originalText,transText,src_lang_code,dest_lang_code):
    src_var = gTTS(text = originalText,lang =src_lang_code) 
    src_var.save("audio_files/srcTTS.mp3")
    
    print(src_lang_code)

    dest_var = gTTS(text=transText,lang=dest_lang_code)
    dest_var.save("audio_files/destTTS.mp3")

def getNews():
    #getting language with max count
    idx, max_value= max(count, key=lambda item: int(item[1]))
    article = ""
    #calling apropriate news function
    if(idx=="English"):
        article = englang()

    elif(idx=="Hindi"):
        article = hindilang()

    elif(idx=="German"):
        article = gerlang()

    elif(idx=="French"):
        article = frenlang()

    elif(idx=="Turkish"):
        article = turklang()
    else:
        article = "Sorry! No news article to display! :("
    return article;


# English
def englang():
    article = ""
    eng=requests.get("https://www.nbcnews.com/")
    soupeng=bs4.BeautifulSoup(eng.text,"lxml")
    for news in soupeng.findAll("h2",{"class":"tease-card__headline"}):
        article = article +"\n"+ news.text
    return article;

# hindi
def hindilang():
    article = ""
    hindi=requests.get("http://www.bbc.co.uk/hindi/")
    souphin=bs4.BeautifulSoup(hindi.text,"lxml")
    for news in souphin.findAll("h3",{"class":"bbc-s8fi4p e1tfxkuo2"}):
        article = article +"\n"+ news.text
    return article;

# german
def gerlang():
    article = ""
    ger=requests.get("http://www.welt.de/")
    soupger=bs4.BeautifulSoup(ger.text,"lxml")
    num=0
    for news in soupger.findAll("a",{"class":"o-link o-teaser__link o-teaser__link--is-headline"}):
        while num<8:
            article = article +"\n"+ news.text
            num+=1
            break
    return article;

# french
def frenlang():
    article = ""
    french=requests.get("http://www.lemonde.fr/")
    soupfr=bs4.BeautifulSoup(french.text,"lxml")
    num=0
    for news in soupfr.findAll("p",{"class":"article__title"}):
        while num<8:
            article = article +"\n"+ news.text
            num+=1
            break
    return article;

# turkish
def turklang():
    article = ""
    turkish=requests.get("http://www.bbc.co.uk/turkish/")
    souptur=bs4.BeautifulSoup(turkish.text,"lxml")
    for news in souptur.findAll("h3",{"class":"bbc-1whbtaf e1tfxkuo2"}):
        article = article +"\n"+ news.text
    return article;

#writing updated language counts to csv file
def writeLangCounts():
    with open("new_csvFile.csv","w",newline="") as writefile:
        countwriter = csv.writer(writefile)
        countwriter.writerow(["Language","count"])
        for i in count:
            countwriter.writerow(i)

    os.remove("Lang_counts.csv")
    os.rename("new_csvFile.csv","Lang_counts.csv")

def statCounter():
    statLang = ""
    statCount = ""
    for i in range(len(count)):
        if(int(count[i][1])>0):
             if(len(statCount)==0):
                statLang = count[i][0]
                statCount = str(count[i][1])
             else:
                statLang = statLang + "|" + count[i][0]
                statCount = statCount + "|" + str(count[i][1])
    return statLang, statCount;
    

if __name__ =="__main__":
    app.run(debug=True,port=5000)