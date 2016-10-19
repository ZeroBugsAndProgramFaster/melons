include(macroLibrary.m4)

	.section __CODE__


//---------------------------------------------------------------
// Melon Thrower functions
//---------------------------------------------------------------

define(smallestMelon, 10)
define(largestMelon,  20)

//
// Picks a melon size randomly in the defined range.
// Returns - the size of the melon, an integer
//
FUNCTION(chooseMelon,
`
	CALL(randomInterval, $smallestMelon, $largestMelon)
')

//
// Throws a melon in the air so the slicer can
// try to catch it. In practice, this passes
// the melon-size on to the shared variable.
// Param1 - Size of the melon
//
FUNCTION(throwMelon,
`
	CALL(putRawMelon)
')

//
// Picks up the melon halfs after it's been sliced.
// Return - integer location of slice on the melon.
//
FUNCTION(getMelonHalfs,
`
	CALL(getSlicedMelon)
')

//
// Evaluates the quality of the slice, and prints
// an appropriate encouragement message.
// param1 - the location of the slice
// param2 - the size of the melon that was sliced
//
FUNCTION(evaluateSlice,
`
define(size,     `%esi')
define(halfSize, `%esi')
define(location, `%edi')

	sarl    $ 1,          size
	cmpl	location, halfSize
	jne	ELSE

	PRINT(perfect)
	jmp	GONE
ELSE:
	subl	location, halfSize
	CALL(abs, %rsi)
	cmpl	$2, %eax
	jg	ELSE2

	PRINT(great)
	jmp	GONE
ELSE2:
	PRINT(practice_more)
	
GONE:
')

//---------------------------------------------------------------
// This is the primary Melon Slicer loop
//---------------------------------------------------------------
FUNCTION(melonThrowerLoop,
`
define(melonSized, %r12d)
define(melonSize,  %r12)
define(readyToThrow, %r13b)

	movl	$-1, melonSized
	movb	$1,  readyToThrow

do(`
	testb	$1, readyToThrow
	je	melon_thrown

	CALL(chooseMelon)
	movl	%eax, melonSized
	PRINT(throwing, melonSize)
	CALL(throwMelon, melonSize)
	movb	$0, readyToThrow

melon_thrown:
	CALL(getMelonHalfs)
	movl	%eax, %r14d
	PRINT(catching, `%r14')
	cmpl	$0, %r14d
	jle	waiting

	CALL(evaluateSlice, %r14, melonSize)
	movb	$1, readyToThrow

waiting:
	movq	_melonThrowerShouldStop@GOTPCREL(%rip), %rax
')while(`$ 0, (%rax)',je)

	xorl	%eax, %eax              #set return value

	movq	_melonThrowerDidStop@GOTPCREL(%rip), %rcx
	movl	$1, (%rcx)
')

.section __STRINGS__
perfect: .asciz    "Perfect slice!\n"
great: .asciz  "Great slice!\n"
practice_more: .asciz  "Keep practicing slicing!\n"
throwing: .asciz  "            Throwing melon %d\n"
catching: .asciz  "            Caught halfs %d\n"
debug:    .asciz  "            debugNum %d\n"
