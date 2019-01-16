
# coding: utf-8
import sys
import os
import copy
import collections
class MazeError(Exception):
	pass
    # def __init__(self, value):
    #     self.value = value
    # def __str__(self):
    #     return repr(self.value)
class Maze:
    def __init__(self,input_string=''):
        self.nex_dic={0:2,1:3,2:0,3:1}
        self.gate_list=[]
        self.grid=[]
        self.reshape=[]
        current_work_directory=os.path.split(os.path.realpath(__file__))[0]
        try:
            input_string=input_string.strip()
            full_directory=os.path.join(current_work_directory,input_string)
            if not os.path.exists(full_directory) or not full_directory.endswith(".txt"):
                print(f"The file does not exit in the {current_work_directory} or its format does not end with '.txt'")
                raise SyntaxError
        except SyntaxError:
            print("Invalid Input!")
            sys.exit()
        self.input=full_directory#full_directory#input_string
        # try:
        check=[]
        with open(self.input) as txt_file:#full_directory
            for line in txt_file:
                current_line=[]
                if line.isspace(): continue
                for ele in line:
                    if ele.isspace():continue
                    if int(ele)>3 or int(ele)<0:
                        raise MazeError('Incorrect input.')
#                        print(ele,end=';')
                    current_line.append(int(ele))
                self.grid.append(current_line)
                check.append(len(current_line))
            check=set(check)
            self.length=list(check)[0]-1
            self.height=len(self.grid)-1
            length=self.length
            height=self.height
            if len(check)>1 or (not length+1 in range(2,32)) or (not height+1 in range(2,42)):
                raise MazeError('Incorrect input.')
            last_line=set(self.grid[height])
            last_colume=set(list(zip(*self.grid))[length])
            if (not last_line.issubset({0,1})) or (not last_colume.issubset({0,2})):
                raise MazeError('Input does not represent a maze.')
        # except MazeError as e:
			# pass
            # print(f'{e.value}')
#             sys.exit()
        
        dic=[{0:[1,1],1:[1,0],2:[0,1],3:[0,0]},{0:[1],1:[1],2:[0],3:[0]},{0:[1],1:[0],2:[1],3:[0]}]
        self.reshape=[[[] for _ in range (length)] for _ in range (height)]
        for j in range(height):
            for i in range (length):
                explore_list=[(i,j),(i+1,j),(i,j+1)]
                for k,ele in enumerate(explore_list):
                    self.reshape[j][i].extend(dic[k][self.grid[ele[1]][ele[0]]])
        self.reshape_dot=[[[0,0,0,0] for _ in range (length+1)] for _ in range (height+1)]
        dic_dot=[{0:0,1:1,2:0,3:1},{0:0,1:0,2:1,3:1},{0:0,1:1,2:0,3:1},{0:0,1:0,2:1,3:1}]
        for j in range(height+1):
            for i in range(length+1):
                explore_list=[(i-1,j),(i,j-1),(i,j),(i,j)]
                for k, ele in enumerate(explore_list):
                    if ele[0]<0 or ele[0]>self.length or ele[1]<0 or ele[1]>self.height:continue
                    self.reshape_dot[j][i][k]=dic_dot[k][self.grid[ele[1]][ele[0]]]
        def gate(self):
            self.count_gate=0
            for k, ele in enumerate(self.reshape[0]):
                if ele[1]==1:
                    self.count_gate+=1
                    self.gate_list.append((0,k))
            for k, ele in enumerate(self.reshape[self.height-1]):
                if ele[3]==1:
                    self.count_gate+=1
                    self.gate_list.append((self.height-1,k))
            reshape_temp=list(zip(*self.reshape))
            for k, ele in enumerate(reshape_temp[0]):
                if ele[0]==1:
                    self.count_gate+=1
                    self.gate_list.append((k,0))
            for k, ele in enumerate(reshape_temp[self.length-1]):
                if ele[2]==1:
                    self.count_gate+=1
                    self.gate_list.append((k,self.length-1))
            self.gate_list=list(set(self.gate_list))
                
        def walls(self): 
            self.count_wall=0
            def iteration(maplist,i,j):
                move_dic={0:[i-1,j],1:[i,j-1],2:[i+1,j],3:[i,j+1]}
                for k, ele in enumerate(maplist[j][i]):
                    if ele:
                        maplist[j][i][k]=0
                        maplist[move_dic[k][1]][move_dic[k][0]][self.nex_dic[k]]=0
                        iteration(maplist,move_dic[k][0],move_dic[k][1])               
            connect=copy.deepcopy(self.reshape_dot)
            for j in range(self.height+1):
                for i in range(self.length+1):
                    if connect[j][i]==[0,0,0,0]:continue
                    iteration(connect,i,j)
                    self.count_wall+=1           
        def access(self):
            self.roam_list =[[False for _ in range (self.length)] for _ in range (self.height)]
            self.count_access=0
            self.count_inacess=0
            def iteration_ac(maplist,i,j):
                self.roam_list[j][i]=True
                move_dic={0:[i-1,j],1:[i,j-1],2:[i+1,j],3:[i,j+1]}
                for k, ele in enumerate(maplist[j][i]):
                    if ele:
                        maplist[j][i][k]=0
                        if move_dic[k][0]<0 or move_dic[k][0]>=self.length or move_dic[k][1]<0 or move_dic[k][1]>=self.height:continue
                        maplist[move_dic[k][1]][move_dic[k][0]][self.nex_dic[k]]=0
                        iteration_ac(maplist,move_dic[k][0],move_dic[k][1])
            block=copy.deepcopy(self.reshape)
            for ele in self.gate_list:
                y ,x =ele[0],ele[1]
                if block[y][x]==[0,0,0,0]:continue
                iteration_ac(block,x,y)
                self.count_access+=1
            for ele in self.roam_list:
                uac=collections.Counter(ele)
                self.count_inacess+=uac[False]        
        def dead_path(self):
            self.count_cul=0
            def iteration_path(maplist,i,j):
                self.roam_list[j][i]='x'
                move_dic={0:[i-1,j],1:[i,j-1],2:[i+1,j],3:[i,j+1]}
                for k, ele in enumerate(maplist[j][i]):
                    if ele:
                        maplist[j][i][k]=0
                        if move_dic[k][0]<0 or move_dic[k][0]>=self.length or move_dic[k][1]<0 or move_dic[k][1]>=self.height:continue
                        maplist[move_dic[k][1]][move_dic[k][0]][self.nex_dic[k]]=0
                        if sum(maplist[move_dic[k][1]][move_dic[k][0]])==1:
                            iteration_path(maplist,move_dic[k][0],move_dic[k][1])
            def iteration_x(maplist,i,j):
                self.roam_list[j][i]='m'
                move_dic={0:[i-1,j],1:[i,j-1],2:[i+1,j],3:[i,j+1]}
                for k, ele in enumerate(maplist[j][i]):
                    if ele:
                        maplist[j][i][k]=0
                        if move_dic[k][0]<0 or move_dic[k][0]>=self.length or move_dic[k][1]<0 or move_dic[k][1]>=self.height:continue
                        maplist[move_dic[k][1]][move_dic[k][0]][self.nex_dic[k]]=0
                        if self.roam_list[move_dic[k][1]][move_dic[k][0]]=='x':
                            iteration_x(maplist,move_dic[k][0],move_dic[k][1])
            self.block_for_a=copy.deepcopy(self.reshape)
            for j in range(self.height):
                for i in range(self.length):
                    if sum(self.block_for_a[j][i])==1 and self.roam_list[j][i]==True:
                        iteration_path(self.block_for_a,i,j)
            block_2=copy.deepcopy(self.reshape)
            for j in range(self.height):
                for i in range(self.length):
                    if self.roam_list[j][i]=='x':
                        iteration_x(block_2,i,j)
                        self.count_cul+=1
            
        def uni_path(self):
            self.count_uni, count_current=0,0
            self.stack=[]
            def iteration_uni(maplist,i,j):
                nonlocal count_current 
                self.roam_list[j][i]='p'
                self.stack.append((i,j))
                move_dic={0:[i-1,j],1:[i,j-1],2:[i+1,j],3:[i,j+1]}
                for k, ele in enumerate(maplist[j][i]):
                    if ele:
                        maplist[j][i][k]=0
                        if move_dic[k][0]<0 or move_dic[k][0]>=self.length or move_dic[k][1]<0 or move_dic[k][1]>=self.height:
                            count_current+=1
                            continue
                        maplist[move_dic[k][1]][move_dic[k][0]][self.nex_dic[k]]=0
                        if self.roam_list[move_dic[k][1]][move_dic[k][0]]==True:
                            iteration_uni(maplist,move_dic[k][0],move_dic[k][1])
            block=copy.deepcopy(self.reshape)
            for ele in self.gate_list:
                y ,x =ele[0],ele[1]
                count_current=0
                if self.roam_list[y][x]==True:
                    iteration_uni(block,x,y)
                    for ele in self.stack:
                        self.roam_list[ele[1]][ele[0]]=count_current
                    self.stack=[]
                    if count_current==2: 
                        self.count_uni+=1  
        gate(self)
        walls(self)
        access(self)
        dead_path(self)
        uni_path(self)
    def analyse(self):
        if self.count_gate==0:
            print(f'The maze has no gate.')
        elif self.count_gate==1:
            print(f'The maze a single gate.')
        else:
            print(f'The maze has {self.count_gate} gates.')
        if self.count_wall==0:
            print(f'The maze has no wall.')
        elif self.count_wall==1:
            print(f'The maze has walls that are all connected.')
        else:
            print(f'The maze has {self.count_wall} sets of walls that are all connected.')   
        if self.count_inacess==0:
            print(f'The maze has no inaccessible inner point.')
        elif self.count_inacess==1:
            print(f'The maze has a unique inaccessible inner point.')
        else:
            print(f'The maze has {self.count_inacess} inaccessible inner points.')
        if self.count_access==0:
            print(f'The maze has no accessible inner area.')
        elif self.count_access==1:
            print(f'The maze has a unique accessible area.')
        else:
            print(f'The maze has {self.count_access} accessible areas.')
        if self.count_cul==0:
            print(f'The maze has no accessible cul-de-sac.')
        elif self.count_cul==1:
            print(f'The maze has accessible cul-de-sacs that are all connected.')
        else:
            print(f'The maze has {self.count_cul} sets of accessible cul-de-sacs that are all connected.')
        if self.count_uni==0:
            print(f'The maze has no entry-exit path with no intersection not to cul-de-sacs.')
        elif self.count_uni==1:
            print(f'The maze has a unique entry-exit path with no intersection not to cul-de-sacs.')
        else:
            print(f'The maze has {self.count_uni} entry-exit paths with no intersections not to cul-de-sacs.')
        

    def display(self):
        fd = open(self.input.replace('.txt','.tex'),'w')  
        fd.write('\documentclass[10pt]{article}\n'+r'\usepackage{tikz}'+'\n'+r'\usetikzlibrary{shapes.misc}'+'\n')
        fd.write(r'\usepackage[margin=0cm]{geometry}'+'\n\pagestyle{empty}\n'+r'\tikzstyle{every node}=[cross out, draw, red]'+'\n\n')
        fd.write(r'\begin{document}'+'\n\n'+r'\vspace*{\fill}'+'\n'+r'\begin{center}'+'\n'+r'\begin{tikzpicture}[x=0.5cm, y=-0.5cm, ultra thick, blue]'+'\n')
        fd.write('% Walls\n')
        for j in range(self.height+1):
            w_flag=0
            for i in range(self.length+1):
                if self.reshape_dot[j][i][2] and w_flag==0:
                    w_flag=1
                    fd.write('    \draw '+f'({i},{j}) -- ')
                elif not self.reshape_dot[j][i][2] and w_flag==1:
                    w_flag=0
                    fd.write(f'({i},{j});\n')
        for i in range(self.length+1):
            w_flag=0
            for j in range(self.height+1):
                if self.reshape_dot[j][i][3] and w_flag==0:
                    w_flag=1
                    fd.write('    \draw '+f'({i},{j}) -- ')
                elif not self.reshape_dot[j][i][3] and w_flag==1:
                    w_flag=0
                    fd.write(f'({i},{j});\n')
        fd.write('% Pillars\n')
        for j in range(self.height+1):
            for i in range(self.length+1):
                if sum(self.reshape_dot[j][i])==0:
                    fd.write('    '+r'\fill[green] ')
                    fd.write(f'({i},{j}) circle(0.2);\n')
        fd.write('% Inner points in accessible cul-de-sacs\n')
        for j in range(self.height):
            for i in range(self.length): 
                if self.roam_list[j][i]=='m':
                    fd.write('    '+r'\node at ')
                    fd.write(f'({i+0.5},{j+0.5}) '+'{};\n')
        fd.write('% Entry-exit paths without intersections\n')
        
        
        for j in range(self.height):
            w_flag=0
            for i in range(self.length):
                if self.roam_list[j][i]==2 and w_flag==0 and self.block_for_a[j][i][0]:
                    w_flag=1
                    fd.write('    \draw[dashed, yellow] '+f'({i-0.5},{j+0.5}) -- ')
                if (self.roam_list[j][i]!=2 or not self.block_for_a[j][i][0]) and w_flag==1:
                    w_flag=0
                    fd.write(f'({i-0.5},{j+0.5});\n')
            if w_flag==1:
                if self.block_for_a[j][i][2]:fd.write(f'({i+1.5},{j+0.5});\n')
                elif self.block_for_a[j][i][0]:fd.write(f'({i+0.5},{j+0.5});\n')
            elif self.roam_list[j][i]==2 and w_flag==0 and self.block_for_a[j][i][2]:
                fd.write('    \draw[dashed, yellow] '+f'({i+0.5},{j+0.5}) -- ')
                fd.write(f'({i+1.5},{j+0.5});\n')
        for i in range(self.length):
            w_flag=0
            for j in range(self.height):
                if self.roam_list[j][i]==2 and w_flag==0 and self.block_for_a[j][i][1]:
                    w_flag=1
                    fd.write('    \draw[dashed, yellow] '+f'({i+0.5},{j-0.5}) -- ')
                if (self.roam_list[j][i]!=2 or not self.block_for_a[j][i][1]) and w_flag==1:
                    w_flag=0
                    fd.write(f'({i+0.5},{j-0.5});\n')
            if w_flag==1:
                if self.block_for_a[j][i][3]:fd.write(f'({i+0.5},{j+1.5});\n')
                elif self.block_for_a[j][i][1]:fd.write(f'({i+0.5},{j+0.5});\n')
            elif self.roam_list[j][i]==2 and w_flag==0 and self.block_for_a[j][i][3]:
                fd.write('    \draw[dashed, yellow] '+f'({i+0.5},{j+0.5}) -- ')
                fd.write(f'({i+0.5},{j+1.5});\n')
        fd.write(r'\end{tikzpicture}'+'\n'+r'\end{center}'+'\n'+r'\vspace*{\fill}'+'\n\n'+r'\end{document}'+'\n')              
        fd.close()
                
        
                

