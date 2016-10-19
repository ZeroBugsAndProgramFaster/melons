dnl Macro for calling functions. Accepts up
dnl to four parameters, any more than that
dnl needs to be done manually.
define(`CALL',
`ifelse(eval($#>1), `1', `movq $2, %rdi')'
`ifelse(eval($#>2), `1', `movq $3, %rsi')'
`ifelse(eval($#>3), `1', `movq $4, %rdx')'
`ifelse(eval($#>4), `1', `movq $5, %rcx')'
`callq _$1'
)

dnl Convenient way to note the
dnl parameter registers
define(`param1', `%rdi')
define(`param2', `%rsi')
define(`param3', `%rdx')
define(`param4', `%rcx')

dnl Macro for defining functions. 
define(`FUNCTION',
`
 .globl _$1
 .align 4, 0x90

_$1:
 pushq %rbp
 movq  %rsp, %rbp

 subq  $ 8, %rsp

 pushq %rbx    
 pushq %r12
 pushq %r13
 pushq %r14
 pushq %r15

 $2

 popq %r15
 popq %r14
 popq %r13
 popq %r12
 popq %rbx

 movq %rbp, %rsp
 popq %rbp
 ret'
)



dnl Abbreviations for various sections
dnl because they are ugly to see
dnl in the actual code
define(`__CODE__', `__TEXT,__text,regular,pure_instructions')
define(`__STRINGS__', `__TEXT,__cstring,cstring_literals')



dnl-----------------------------------------------
dnl Macros for loops. These can be cleaned up.
dnl-----------------------------------------------

dnl This is a do-while loop.
dnl Not nestable, because
dnl label names will get confused.
dnl There is a way to do this nested:
dnl I will figure it out when needed.
define(`DO_LABEL', 1)
define(`do', `define(`DO_LABEL', eval(DO_LABEL+1))' `do_label`'DO_LABEL': $1)
define(`while',
`cmpl $1
$2 do_label`'DO_LABEL')



dnl-----------------------------------------------
dnl Macros for some common function calls
dnl-----------------------------------------------

define(`PRINT',
`	leaq	$1(%rip), %rdi
	ifelse(eval($#>1), `1', `movq $2, %rsi')
	ifelse(eval($#>2), `1', `movq $3, %rdx')
	callq	_printf')


define(`LOCK',
movq _`'$1`@GOTPCREL(%rip), %rdi
callq _pthread_mutex_lock')

define(`UNLOCK',
movq _`'$1`@GOTPCREL(%rip), %rdi
callq _pthread_mutex_unlock')
