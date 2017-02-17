##Crash分析工具(Tool for analyse iOS Crash）

<img src="https://raw.githubusercontent.com/Jsonmess/Crasher/master/CrashAnalyseTool/Assets.xcassets/AppIcon.appiconset/timg-6.png" width="100" height="100"/>

工具基于Xcode自带命令**“symbolicatecrash”**制作；希望能为大家节省一些时间！  

This Tool use Xcode internal command line tool **“symbolicatecrash”** ，Hope to help you save some time!


####一. 为何要做这个工具（why make this tool）

   About **symbolicatecrash**  
   ENG： [How to symbolicate iOS crash reports] (https://marmalade.zendesk.com/hc/en-us/articles/202865223--M0102-How-to-symbolicate-iOS-crash-reports)   
   中文：[使用symbolicatecrash解析了一个crash log](http://www.jianshu.com/p/0a1c029e910f)  

操作**symbolicatecrash**是否觉得有些繁琐、浪费时间？
 
Now You Know what should we do if we want the **symbolicatecrash** to analyse ios crash log file. is tedious ?

####二.使用说明（The instructions）
   This tool is very simple to use,here is the app screenshots（截图）：  
   <img src="https://raw.githubusercontent.com/Jsonmess/Crasher/master/Screenshots/screen.png" width="300" height="280"/>
#####操作步骤（Steps） 
######中文：  
    1)将dSYM文件和.crash 文件以及 .app 文件放到同一个文件夹；  
    2)将.crash 拖动到 工具 提示区，等待解析完成；
    3）解析成功后，会创建一个与.crash同名的.log文件，即为解析后的文件； 
######ENG： 
    1) Put "dSYM"、".crash" file and “.app”file in same folder;
    2) Drag ".crash" to our Tool,and waiting ...;
    3) When finished parsing the log,there will create a ".log" file 
       whitch has the same name as ".crash" file;



