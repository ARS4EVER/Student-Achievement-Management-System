assume cs:code, ds:data, ss:stack 
data segment 
    menu db 0dh,0ah
         db'********************* Student Grade Management System Menu *********************',0dh,0ah
         db'--------------------------------------------------------------------------------',0dh,0ah
         db'| 1. Enter student basic info & 9 assignment scores|  2. Search by student ID  |',0dh,0ah
         db'| 3. Search by student name                        |  4. Sort by total score   |',0dh,0ah
         db'| 5. Score segment statistical analysis            |  6. Exit the system       |',0dh,0ah
         db'--------------------------------------------------------------------------------',0dh,0ah,'$'

    ; 功能表：对应功能 1 - 6 的函数地址
    funtable dw function1,function2,function3,function4,function5,function6  

    ; 学号表、姓名表
    idtable dw id1,id2,id3,id4,id5,id6,id7,id8,id9,id10,id11
    nametable dw name1,name2,name3,name4,name5,name6,name7,name8,name9,name10,name11

    ; 提示信息
    welcome db '*****************************  Welcome to Grade System!  *******************',0dh,0ah,'$'
    choice db 'Please enter your choice (1-6): $'
    error0 db 'Invalid input! Please enter a number between 1 and 6. $'
    line db 0dh,0ah,'$'
    thank db '*****************************  Thanks for using!  ****************************',0dh,0ah,'$'

    ; 功能相关提示
    score db'Student ID   |   Name   | Assignment 01-09 Scores (abbreviated)','$'
    studentshu db 'Enter the number of students: $'
    SearchID db 'Enter student ID to search: $'
    Searchyes db 'Search successful! Details as follows: $'
    showname db 'Student name: $'
    showid db 'Student ID: $'
    showping db 'Average assignment score: $'
    showbig db 'Major project score: $'
    showfinal db 'Final exam score: $'
    Searchname db 'Enter student name to search: $'
    sort db '   ID   |   Name   | Avg Assign | Major Proj | Final Score | Rank','$'
    show db '**************************** Score Statistical Analysis **********************',0dh,0ah,'$'
    show0 db '  Score range 90-100: $'
    show1 db '  Score range 80-89: $'
    show2 db '  Score range 60-79: $'
    show3 db '  Score range 0-59: $'
    show4 db '  Overall average score: $'
    show5 db '  Highest score recorded: $'
    show6 db '  Lowest score recorded: $'

kongge db '           ','$'      ;空格——排版优化
kongge0 db ' ','$'               ;空格——排版优化
kongge1 db '    ','$'            ;空格——排版优化
name1 db 12,?,12 dup('$')        ;存放姓名
name2 db 12,?,12 dup('$')  
name3 db 12,?,12 dup('$')             
name4 db 12,?,12 dup('$')
name5 db 12,?,12 dup('$')         
name6 db 12,?,12 dup('$')
name7 db 12,?,12 dup('$')  
name8 db 12,?,12 dup('$')             
name9 db 12,?,12 dup('$')
name10 db 12,?,12 dup('$') 
name11 db 12,?,12 dup('$')        ;可继续增加存放量
ID1 db 12,?,12 dup('$')           ;存放ID
ID2 db 12,?,12 dup('$')  
ID3 db 12,?,12 dup('$')             
ID4 db 12,?,12 dup('$') 
ID5 db 12,?,12 dup('$')
ID6 db 12,?,12 dup('$')           
ID7 db 12,?,12 dup('$')  
ID8 db 12,?,12 dup('$')             
ID9 db 12,?,12 dup('$') 
ID10 db 12,?,12 dup('$')
ID11 db 12,?,12 dup('$')	      ;可继续增加存放量
student_count dw 0                ;学生数量
highest_score dw 0                ;最高成绩
lowest_score dw 100               ;最低成绩
average_score dw 0                ;平均成绩
tmp dw 0                          ;用来计算的临时空间
tmp1 dw 0
tmp2 dw 0 
ten dw 10                         ;数字十，方便运算
score_analyze dw 0,0,0,0,'$'	  ;保存四个分数段中的人数
score_enter dw 4,2,1              ;分数输入时需要的辅助数字便于计算
ping_score dw 20 dup(?)           ;平时成绩，大作业成绩和总成绩
big_score dw 20 dup(?)            ;大作业成绩
final_score dw 20 dup(?)          ;总成绩
rank dw 20 dup(0)                 ;排名
divnum dw 1000,100,10,1           ;除数,数字转ascll用的
result db 0,0,0,0,'$'			  ;存放除的结果
data ends	
	
stack segment stack 
      db 256 dup (0) 
stack ends 
 
;------------------------------宏定义------------------------------------
;------------------------------输出提示语-------------------------------
out_dx macro str								
	push dx
	push ax
	lea dx,str
	mov ah,09h
	int 21h
	pop ax
	pop dx
endm
;------------------------------保护寄存器-------------------------------
push_all macro
	 push ax
     push bx
	 push cx
	 push dx
	 push si
	 push di
endm
pop_all macro
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
endm
;------------------------------将数字转为ascll码-------------------------------
; 定义output_ascll宏，用于将一个32位无符号整数转为ascll码
output_ascll macro
local ascll_0,ascll_1,ascll_2
	push_all
	mov si,offset divnum
	mov di,offset result  
	mov cx,4
ascll_0:
	mov dx,0   
	div word ptr [si]
 
	add al,30h                  ;转为ascll码
	mov byte ptr [di],al
	inc di
	add si,2
	mov ax,dx                 
	loop ascll_0
 
	mov cx,3  
	mov di,offset result
 
ascll_1:
	cmp byte ptr [di],'0'
	jne ascll_2 
	inc di
	loop ascll_1
 
ascll_2:
	mov dx,di
	mov ah,9
	int 21H
    pop_all
endm
;------------------------------功能开始前的初始化值-------------------------------
begin_all macro
	mov ax,0
	mov bx,0
	mov cx,student_count
	mov dx,0
	mov di,0
	mov si,0
endm
;------------------------------宏定义结束------------------------------------
;------------------------------start-----------------------------------------
code segment
start:
    mov ax,data
	mov ds,ax
	mov es,ax
	out_dx welcome             ;输出欢迎提示语
start0:	
    out_dx menu                ;输出菜单	
start1:	
    out_dx choice              
	mov al,01h				   ;输入数字，结果放在al中
	mov ah,0ch
	int 21h					   ;输入选项（1-6）
	sub al,30h				   ;由ascll转为数字
	 
	cmp al,0
	jb exit0                    
	cmp al,6					
	ja exit0                  ;若小于零或大于六，则跳转错误
    
	mov bx,0
	dec al
	mov bl,al                     
	add bx,bx
	out_dx line
	call funtable[bx]
	jmp start0                ;重新返回菜单
 
exit0:  
    out_dx line              
	out_dx error0				;提示输入有误
	jmp start1                  ;重新输入
 
;------------------------------function1输入-------------------------------	
function1:
	push_all
	out_dx studentshu
	mov bx,0
fun1_1:
	mov al,01h                                  
	mov ah,0ch
	int 21h               ;输入学生数量
    sub al,30h           
	jb fun1_2                            
	cmp al,9                                
	ja fun1_2              ;小于9大于0则跳转，为一位数
 
	mov ah,0              ;两位数则继续执行                           
	xchg ax,bx
	mul ten[0]     
	xchg ax,bx
	add bx,ax
	jmp fun1_1
fun1_2:
	lea si,student_count
	mov word ptr [si],bx
 
    begin_all
	out_dx line
	out_dx score  
       
f1_1:
    
	push ax
	push dx
	out_dx line
	mov dx,idtable[si]
	mov al,0ah                               
	mov ah,0ch                          
	int 21H               ;输入学生的学号
	mov ah,02h
    mov dx,180dh          ;设定光标到第24行13列
    int 10h
 
	mov dx,nametable[si]
	mov al,0ah                         
	mov ah,0ch                     
	int 21H              ;输入学生姓名
 
    mov ah,02h
    mov dx,181ah         ;设定光标到第24行26列
    int 10h
	
	pop dx
	pop ax
 
	mov tmp2,cx       
	mov cx,8										 
	mov ax,0
 
f1_2:   
	push si                               
	push ax
	push bx
	mov bx,0
n1:
	mov al,01h                              
	mov ah,0ch
	int 21h
 
    sub al,30h                                 ;改变为数字
	jl n2                                      ;小于0，跳转
	cmp al,9                                   ;大于9，跳转
	jg n2 
	cbw                                        ;AL的内容扩展到AH,形成AX中的字。
 
	xchg ax,bx                                
	mul ten[0] 
	xchg ax,bx                      
	add bx,ax                               
	dec score_enter[2]
	cmp score_enter[2],0
	ja n1 
n2:
	mov score_enter[2],2
	lea si,tmp
	mov word ptr [si],bx
	pop bx
	pop ax
	pop si
 
 
	add ax,tmp                             ;把8次平时成绩加起来
	mov tmp,0
	out_dx kongge0
	loop f1_2
 
	mov cx,tmp2                             ;除以8得到平时成绩
	mov bl,8 
	div bl
	mov dl,al
	mov dh,0
	mov ping_score[si],dx                    ;放在ping_score中
 
	mov tmp1,dx                             ;这里其实是x4，为了简便加了4次
	add tmp1,dx							    ;(平时x4+大作业x6）/10
	add tmp1,dx
    add tmp1,dx
 
	push si                                 
	push ax
	push bx
	mov bx,0
n3:
	mov al,01h                                  ;功能号和清除缓存区
	mov ah,0ch
	int 21h
 
    sub al,30h                                  ;改变为数字
	jl n4                                      ;小于0，跳转
	cmp al,9                                    ;大于9，跳转
	jg n4 
	cbw ;AL的内容扩展到AH,形成AX中的字。
 
	xchg ax,bx                                
	mul ten[0]                                  ;*10 
	xchg ax,bx                      
	add bx,ax                               
	dec score_enter[2];1
	cmp score_enter[2],0
	ja n3 ;大于则跳转
n4:
	mov score_enter[2],2
	lea si,tmp
	mov word ptr [si],bx
	pop bx
	pop ax
	pop si
	
	mov dx,tmp
	mov tmp,0
	mov big_score[si],dx                    ;对应大作业成绩
 
	add tmp1,dx                             ;大作业*6，加上去
	add tmp1,dx
	add tmp1,dx
	add tmp1,dx
	add tmp1,dx
	add tmp1,dx	
 
 
	mov ax,tmp1
	mov bl,10
	div bl                                    ;除以10，得到最终成绩
	mov dl,al
	mov dh,0
	mov final_score[si],dx                    ;存入最终成绩
 
	;计算各个分数段的人数
	cmp dx,60                                 ;跳转到相应的计数部分
	jl f1_3                                   
 
	cmp dx,80
	jl f1_4
 
	cmp dx,90
	jl f1_5
 
	inc score_analyze[6]                      ;score_analyze是各个分数段的统计人数，
	jmp f1_6
f1_3:
	inc score_analyze[0]
	jmp f1_6
f1_4:
	inc score_analyze[2]
	jmp f1_6
f1_5:
	inc score_analyze[4]
	jmp f1_6
 
f1_6:
	add average_score,dx                          ;总分累加
	cmp dx,highest_score
	jng f1_7                
	call highmove
f1_7:
	cmp dx,lowest_score
	jnl f1_8
	call lowmove
f1_8:
	add si,2                                       
	dec cx
	jcxz f1ret
	jmp near ptr f1_1                             
f1ret:
	pop_all
	ret
highmove:
	mov highest_score,dx                           ;改变最低成绩和最高成绩
	ret
lowmove:
	mov lowest_score,dx
    ret
		
;------------------------------function2查找学号-------------------------------	
function2:
	push_all
	begin_all
	out_dx SearchID
	             
	push ax
	push dx
	mov dx,idtable[20]
	mov al,0ah                                  
	mov ah,0ch                                 
	int 21H                        ;输入学号
	pop dx
	pop ax
	out_dx line
f2_0:
	mov tmp2,cx
	mov cx,10              
	lea di,ID11           
	add di,2
	mov si,idtable[bx]
	add si,2
	repz cmpsb
 
	jz f2_1
	add bx,2
	mov cx,tmp2
	loop f2_0
 
	out_dx line
	out_dx error0                     ;查询不到学号
	jmp f2_2
 
f2_1:
	out_dx Searchyes                  ;查找成功
	out_dx line 
 
	out_dx showid					;输出id
	mov dx,idtable[bx]
	add dx,2
	mov ah,9h
	int 21h
    out_dx showname				   ;输出名字
	mov dx,nametable[bx]
	add dx,2
	mov ah,9h
	int 21h
	out_dx line
 
	out_dx showping                   ;输出平时成绩
	mov ax,ping_score[bx]
	output_ascll
 
	out_dx showbig                    ;输出大作业成绩
	mov ax,big_score[bx]
	output_ascll
 
	out_dx showfinal                   ;输出总成绩
	mov ax,final_score[bx]
	output_ascll
 
	out_dx line                         
 
f2_2:                                   ;重置空间，方便下次继续查询不会出错
	mov bx,idtable[20]
	inc bx
	mov byte ptr [bx],0
	inc bx
	mov cx,10
f2_3:
	mov byte ptr [bx],'$'
	inc bx
	loop f2_3
	
	pop_all
	ret
 ;------------------------------function3查找名字-------------------------------	       
function3:
	push_all
    begin_all
 
	out_dx Searchname
	mov dx,nametable[20]
	mov al,0ah                                  
	mov ah,0ch
	int 21H                               ;输入查找姓名
	out_dx line
f3_0:
	mov tmp2,cx
	mov cx,10                             ;姓名最长为10
	lea di,name11
	add di,2
	mov si,nametable[bx]
	add si,2
	repz cmpsb
 
	jz f3_1                               
	add bx,2
	mov cx,tmp2
	loop f3_0
    out_dx line
	out_dx error0    
	jmp f3_2
 
f3_1:
	out_dx Searchyes                        ;提示查找成功
	out_dx line 
 
	
	out_dx showid							;输出id
	mov dx,idtable[bx]
	add dx,2
	mov ah,9h
	int 21h
    out_dx showname							;输出名字
	mov dx,nametable[bx]
	add dx,2
	mov ah,9h
	int 21h
	out_dx line
 
	out_dx showping                          ;输出平时成绩
	mov ax,ping_score[bx]
	output_ascll
 
	out_dx showbig                          ;输出大作业成绩
	mov ax,big_score[bx]
	output_ascll
 
	out_dx showfinal                         ;输出总成绩
	mov ax,final_score[bx]
	output_ascll
 
	out_dx line 
f3_2:;重置
	mov bx,nametable[40]
	inc bx
	mov byte ptr [bx],0
	inc bx
	mov cx,10
f3_3:
	mov byte ptr [bx],'$'
	inc bx
	loop f3_3
 
	pop_all
    ret
 ;------------------------------function4排序-------------------------------	   
function4:  ;排序功能有进行参考
    push_all
    begin_all
    mov dx,student_count                        
	sub dx,1 
sort1:
	mov bl,0  
	cmp dx,0							   
	jle sortexit
	mov cx,dx                              ;内循环次数
	mov si,0                               ;从第0位开始
 
sort2:
	mov ax,final_score[si]
	cmp ax,final_score[si+2]                ;该字形数据与后一位字形数据比较
	jle dontchange                          ;小于或等于则不交换
 
	xchg ax,final_score[si+2]               ;交换总成绩
	mov final_score[si],ax
 
	mov ax,big_score[si]                    ;交换大作业成绩
	xchg ax,big_score[si+2]
	mov big_score[si],ax	
	
	mov ax,ping_score[si]                   ;交换平时作业成绩
	xchg ax,ping_score[si+2]
	mov ping_score[si],ax	
 
	mov ax,nametable[si]                    ;交换姓名
	xchg ax,nametable[si+2]
	mov nametable[si],ax
 
	mov ax,idtable[si]                      ;交换学号
	xchg ax,idtable[si+2]
	mov idtable[si],ax	
	mov bl,0ffh                            
 
dontchange:
	add si,2
	loop sort2
	dec dx
	cmp bl,0                                 ;检查交换标志
	jmp sort1	                             ;作为是否继续比较排序的标志
sortexit:
	mov bx,0
	mov cx,student_count
rk:
	mov rank[bx],cx
	add bx,2
	loop rk
 
	mov bx,0
	mov cx,student_count
	out_dx sort
f4show:
    out_dx line
	mov dx,idtable[bx]
	add dx,2
	mov ah,9h
	int 21h
	
    mov ah,02h
    mov dx,180dh                         ;设定光标到第24行13列
    int 10h				
	
	mov dx,nametable[bx]                 ;输出名字
	add dx,2
	mov ah,9h
	int 21h
	
	mov ah,02h
    mov dx,181ah                         ;设定光标到第24行26列
    int 10h
	
	out_dx kongge1
	mov ax,ping_score[bx]
	output_ascll
	out_dx kongge
 
	mov ax,big_score[bx]
	output_ascll
	out_dx kongge
 
	mov ax,final_score[bx]
	output_ascll
	out_dx kongge
 
	mov ax,rank[bx]
	output_ascll
	
	add bx,2
	dec cx
	jcxz f4ret
	jmp near ptr f4show
f4ret:
 
	pop_all
    ret
;------------------------------function5统计-------------------------------	
function5:
	push_all                       
	begin_all
	mov bx,student_count
 
    out_dx show
    out_dx line
	
	out_dx show0
	mov ax,score_analyze[6]
	output_ascll
	out_dx line	
 
	out_dx show1
	mov ax,score_analyze[4]
	output_ascll
	out_dx line	
	
	out_dx show2
	mov ax,score_analyze[2]
	output_ascll
	out_dx line	
	
	out_dx show3
	mov ax,score_analyze[0]                                
	output_ascll
	out_dx line
	
	out_dx show4 
	mov ax,average_score
	div bl
	mov dl,al
	mov dh,0
	mov ax,dx
	output_ascll
	out_dx line
 
	out_dx show5
	mov ax,highest_score
	output_ascll
	out_dx line
 
	out_dx show6
	mov ax,lowest_score
	output_ascll
	out_dx line	
	pop_all
	ret
;------------------------------function6退出-------------------------------	
function6:   
	out_dx thank           
	mov ax,4c00h
	int 21h
	ret
 
code ends
end start