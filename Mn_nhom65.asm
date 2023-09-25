##################################################################
####----------------------------------------------------------####
####         CODE CONG VA TRU 2 SO THUC CHINH XAC DON         ####
####                       Nhom 65, L02                       ####
####----------------------------------------------------------####
##################################################################

.data
	# Khong gian Buffer cho du lieu 4 byte
	dulieu1:	.space 4			
	dulieu2:	.space 4
	# Khoi tao bien Ket qua
	ketqua:		.float 1.0	
	# Ten	file va khoi tao gia tri cho File Descriptor
	tenfile:	.asciiz "FLOAT2.BIN" 
	fdescr:		.word 0 

# Cac cau nhac nhap/xuat du lieu
	str_dl1:	.asciiz "Du lieu 1 = " 
	str_dl2:	.asciiz "Du lieu 2 = " 
	str_kq:		.asciiz "Ket qua   = "
	str_loi:	.asciiz "Mo file bi loi." 

.text
	main:
		#------Mo file-------#
		la $a0, tenfile 
		li $a1, 0 #a1=0 (che do chi doc)
		li $v0, 13 	
		syscall 
		bltz $v0, baoloi #(bao loi neu $v0 < 0)
		sw $v0, fdescr

		#------Doc file------#
		#---4 byte dau---#
		lw $a0, fdescr
		la $a1, dulieu1
		li $a2, 4
		li $v0, 14
		syscall
		#---In du lieu 1---#
		la $a0, str_dl1
		li $v0, 4
		syscall
		lwc1 $f12, dulieu1
		li $v0, 2 
		syscall 
		#---In xuong dong---#
		li $a0, '\n' 
		li $v0, 11 
		syscall
		
		#---4 byte sau---#
		lw $a0, fdescr
		la $a1, dulieu2
		li $a2, 4
		li $v0, 14
		syscall
		#---In du lieu 2---#
		la $a0, str_dl2
		li $v0, 4 
		syscall 
		lwc1 $f12, dulieu2
		li $v0, 2 
		syscall 
		
		#------Dong file------#
		lw $a0, fdescr 
		li $v0, 16 
		syscall
####----------------------Ket thuc buoc 0---------------------####

#----------------Buoc 1: Trich xuat cac thanh phan---------------#
		#---Load so thuc 1 va vao $a0 va $a1---#
		lw $a0, dulieu1
		lw $a1, dulieu2
		#---Jump den ham MYADD---#
		jal MYADD		
		#---Gia tri tra ve luu o $v0---#
		sw $v0, ketqua
		
		#---In xuong dong---#
		li $a0, '\n' 
		li $v0, 11 
		syscall
		
		#---In ket qua---#
		la $a0, str_kq 
		li $v0, 4 
		syscall 
		lwc1 $f12, ketqua 
		li $v0, 2 
		syscall 
		j Kthuc
	baoloi: #---Xuat chuoi bao loi roi ket thuc---#
		la $a0, str_loi 
		li $v0, 4 
		syscall 
	Kthuc:
		#---Ket thuc chuong trinh---#
		li $v0, 10		
		syscall 		
		
#-------Ham lay 2 so thap phan chinh xac don o $a0 va $a1--------#
#-------gia tri tong se duoc tra ve o $v0------------------------#
	MYADD:
		#---Khoi tao gia tri cho $s0 va $s1---#
		li $s0, 0
		li $s1, 0
		
#-------------Lay dau, so mu, dinh tri cua $a0 va $a1------------#
#------Su dung $t0, $t1, $t2 cho $a0 va $t3, $t4, $t5 cho $a1----#
		
		# copy $a0 va $a1 vao $t0, $t3
    		andi $t0, $a0, 0xFFFFFFFF
    		andi $t3, $a1, 0xFFFFFFFF
		
		# Lay phan dinh tri
    		andi $t2, $t0, 0x007FFFFF
    		andi $t5, $t3, 0x007FFFFF  
		 # Dich $t0, $t3 sang phai 
    		srl $t0, $t0, 23 
    		srl $t3, $t3, 23
		 # Lay phan mu
    		andi $t1, $t0, 0x000000FF
    		andi $t4, $t3, 0x000000FF
    		# Dich tiep sang phai, bit con lai la dau
    		srl $t0, $t0, 8 
    		srl $t3, $t3, 8

#-------------Kiem tra truong hop Zeros-------------------------#
#---------Mot so rat nho khi phan mu = 0 vi 0-127 = -127---------#
		beq $t1, $0, zeros
		beq $t4, $0, zeros
		
		# Chen them 1 bit vao ben trai phan dinh tri
		ori $t2, $t2, 0x00800000
		ori $t5, $t5, 0x00800000
		
#---------------Sau khi thuc hien doan code tren :--------------#
#---------------$a0 : | $t0 | $t1 | $t2 |-----------------------#
#---------------$a1 : | $t3 | $t4 | $t5 |-----------------------#		
		
####----------------------Ket thuc buoc 1---------------------####

#-----Buoc 2: So sanh phan mu va jump den vi tri thich hop-------#
		
		#----Neu phan mu bang nhau, khong can-------#
		#----phai dieu chinh, nhay den exit_loop----#
		beq $t1, $t4, exit_loop
		
		#----Neu mu cua so $a1 lon hon,---#
		#----jump den loop_a1_larger------#
		slt $t6, $t4, $t1
		beq $t6, $0, loop_a1_larger
		#----Neu khong thi mu $a0 lon hon,-----#
		#---thuc hien vong lap loop_a0_larger--#
		loop_a0_larger:
		beq $t1, $t4, exit_loop	# Kiem tra dieu kien dung
		
		#----Load cac bit RS bi cat de lam tron----#
		and $t7, $t5, 1
		sll $t7, $t7, 1
		and $t6, $s1, 1
		sll $t6, $t6, 1
		or $s1, $t6, $s1
		srl $s1, $s1, 1
		or $s1, $s1, $t7
		
		# Dich dinh tri cua $a1 qua phai
		srl $t5, $t5, 1
		# Cong 1 vao so mu
		addi $t4, $t4, 1
		# Loop lai vong lap
		j loop_a0_larger

		loop_a1_larger:
		beq $t1, $t4, exit_loop # Kiem tra dieu kien dung
		
		#----Load cac bit RS bi cat de lam tron----#
		and $t7, $t2, 1
		sll $t7, $t7, 1
		and $t6, $s0, 1
		sll $t6, $t6, 1
		or $s0, $t6, $s0
		srl $s0, $s0, 1
		or $s0, $s0, $t7
		
		#---Dich dinh tri cua $a0 qua phai---#
		srl $t2, $t2, 1
		#---Cong 1 vao so mu----#
		addi $t1, $t1, 1
		#---Loop lai vong lap----#
		j loop_a1_larger
####----------------------Ket thuc buoc 2---------------------####		

exit_loop:
#-----Buoc 3: Sau khi so mu bang nhau, cong 2 phan dinh tri------#
		#----Chen 2 bit RS vao cuoi phan dinh tri--#
		#----(dinh tri bay gio co 26 bit)----------#
		sll $t2, $t2, 2
		sll $t5, $t5, 2
		add $t2, $t2, $s0
		add $t5, $t5, $s1
		
	#----Kiem tra xem 2 phan dinh tri co cung dau khong----#
		#---Neu khong, jump den Difference---#
		bne $t0, $t3, difference	
		#---Neu cung dau, cong 2 dinh tri---#
		add $t6, $t2, $t5			
		#---Dich bit dau sang trai 31 de ghep dau---#
		sll $t0, $t0, 31
		#---Chuan hoa---#
		j normalization
		
	#---Xu li khi 2 dinh tri khong cung dau---#
	#---Tim xem so nao am de doi cho, lay so--#
	#---duong tru so am-----------------------#
	difference:	
		#---Neu dau cua $a0 la am-------#
		#---Branch den Sub_first_elem---#
		#---de lay $a1 + (-$a0)---------#
		bne $t0, $0, sub_first_elem
		
		#---Neu khong thi dau cua $a1 la am---#
		#---lay $a0 + (-$a1)------------------#
		sub $t5, $0, $t5 	#(-$a1)
		add $t6, $t5, $t2	#$a0 + (-$a1)
		
		# Kiem tra xem ket qua la am hay duong#
		andi $t0, $t6, 0x80000000
		#----Neu bit dau = 0, no la so duong,-#
		#----tien hanh chuan hoa--------------#
		beq $t0, $0, normalization
		#----Neu la am thi doi dau roi chuan hoa
		sub $t6, $0, $t6
		j normalization

	sub_first_elem:
		# Vi $a0 am nen ta lay $a1 + (-$a0)
		sub $t2, $0, $t2	#(-$a0)
		add $t6, $t5, $t2	#$a1 + (-$a0)
		
		# Kiem tra xem ket qua la am hay duong#
		andi $t0, $t6, 0x80000000
		#---Neu bit dau = 0, no la so duong---#
		#---tien hanh chuan hoa---------------#
		beq $t0, $0, normalization
		# Neu la am thi doi dau roi chuan hoa
		sub $t6, $0, $t6 

####----------------------Ket thuc buoc 3---------------------####

#----------------------Buoc 4: Chuan hoa ket qua-----------------#
	normalization:
		#---Luu 2 bit RS cuoi vao $s0---#
		#---va cat 2 bit RS ben phai----#
		#---cua dinh tri cua ket qua----#
		andi $s0, $t6, 3
		srl $t6, $t6, 2
		
	#----Kiem tra xem dinh tri can chuan hoa len hay xuong
		andi $t2, $t6, 0xFF000000 
		# Neu dinh tri < 1000 0000 0000 0000 0000 0000
		# VD: 0111 0000 0000 0000 0000 0000
		# Thi chuan hoa xuong (dich trai, giam mu)
		blt $t6, 0x00800000, normalization_loop_decrease
		
		# Neu khong thi kiem tra xem co
		# bi vuot qua 24 bit khong
		# Neu khong (cac bit o ben trai bit 23 deu bang 0)
		# thi khong cann lam gi ca
		beq $t2, $0, norm_loop_exit
		
		# Neu co bit tran (ton tai bit '1' ben trai bit 23)
		# thi chuan hoa len (dich phai, tang mu)
		# va luu lai cac bit RS bi day ra ngoai de lam tron
	normalization_loop_increase:
		li $t7, 0x01000000	
		# Kiem tra dieu kien dung
		#   < 0001 0000 0000 0000 0000 0000 0000
		# VD: 0000 1111 1111 1111 1111 1111 1111
		blt $t6, $t7, norm_loop_exit	
		#----Load cac bit RS bi cat de lam tron----#
		and $t7, $t6, 1		
		sll $t7, $t7, 1
		addi $t7, $t7, 1
		and $t3, $t6, 1
		sll $t3, $t3, 1
		or $s0, $t3, $s0
		srl $s0, $s0, 1
		and $s0, $s0, $t7
		
		#---Dich dinh tri sang phai---#
		srl $t6, $t6, 1
		
		#---Cong 1 vao phan mu--------#
		li $t7, 0x000000FF
		addi $t1, $t1, 1
		beq $t1, $t7, overflow
		
		j normalization_loop_increase
		
	normalization_loop_decrease:
		# Kiem tra dieu kien dung
		#   > 0000 1000 0000 0000 0000 0000 0000
		# VD: 0000 1000 0000 0000 0000 0000 0001
		li $t7, 0x00800000
		bge $t6, $t7, norm_loop_exit
		
		# Dich dinh tri sang trai 
		sll $t6, $t6, 1
		
		# Tru 1 vao so mu
		addi $t1, $t1,-1
		beq $t1, $0, underflow
		j normalization_loop_decrease
####----------------------Ket thuc buoc 4---------------------####

#----------------------Buoc 5: Lam tron ket qua------------------#	
	norm_loop_exit:
		# Sau khi chuan hoa, tien hanh lam tron
		# cac bit bi day ra ngoai
		# Chi lam tron neu bit RS = 11
		# hoac khi RS = 10 va bit ben trai R = 1
		li $t8, 2
		blt $s0, $t8, after_rounding
		slti $t9,$t8, 3
		andi $t8, $t6, 1
		and $t8,$t8,$t9
		beqz $t8, after_rounding
		
		# Lam tron
		addi $t6 $t6, 1
		li $t8, 0x01000000
		# Neu sau khi lam tron khong bi tran bit
		# thi ket thuc lam tron
		blt $t6, $t8, after_rounding
		# Neu tran thi dich phai dinh tri, tang mu
		srl $t6, $t6, 1
		addi $t1, $t1, 1
		# Neu sau khi chuan hoa ma van bi tran thi
		# In ket qua tran`
		li $t7, 0x000000FF
		beq $t1, $t7, overflow
####----------------------Ket thuc buoc 5---------------------####
		
#-------------Buoc 6: Ghep thanh phan, xuat ket qua--------------#
		# Sau khi lam tron, ghep cac thanh phan
		# lai voi nhau va ket thuc
	after_rounding:
		# Bo bit 1 o dau, chi chua lai phan thap phan
		andi $t6, $t6, 0xFF7FFFFF
		# Dich phan mu den vi tri thich hop de ghep
		sll $t1, $t1, 23 
		# Ghep cac thanh phan lai voi nhau
		or $v0, $t1, $t6
		or $v0, $v0, $t0
	exit:
		jr $ra 		# return to main
####----------------------Ket thuc buoc 6---------------------####

#-------------------Cac truong hop dac biet----------------------#
	#-----------So rat nho------------#
	zeros:	
		# Neu 1 trong 2 la 1 so 0 thi ket qua
		# se bang voi gia tri cua so con lai
		# Neu ca 2 so deu la 0 thi ket qua
		# se bang 0
		li $t0, 0
		beq $t1, $t4, underflow
		beq $t1, $0, first_arg_zero
		
		move $v0, $a0
		jr $ra
		
	first_arg_zero:
		move $v0, $a1
		jr $ra
	#-------------Vo cung------------#
	# Khi so mu =1111 1111 thi MIPS se khong
	# the hien thi duoc so do
	# Khi do, ket qua se bang gia tri 0x07F800000
	# or voi dau de ra Infinity hoac -Infinity
	overflow:
		li $v0, 0x07F800000
		or $v0, $v0, $t0
		jr $ra
	# So cham dong (+) chinh xac don nho nhat may tinh
	# co the hien duoc la 1E-45, neu ket qua nho hon
	# so nay thi se khong hien thi duoc, ta goi no la 
	# underflow, de xu li, ta se cho ket qua = 0.0 hoac -0.0  
	underflow:
		li $v0, 0
		or $v0, $v0, $t0
		jr $ra
		