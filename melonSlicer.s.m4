include(macroLibrary.m4)
.section __CODE__

//------------------------------------------------------
// Melon Slicer routines
//------------------------------------------------------

//
// Return - Size of melon thrown by melonthrower
//
FUNCTION(catchMelon,
`
	CALL(getRawMelon)
')

//
// Slices melons by choosing a point randomly.
// Param1 - Size of the melon to slice.
// Return - point on melon where the slice happened
//
FUNCTION(sliceMelon,
`	movq	param1, param2
	CALL(randomInterval, $ 1)
')

//
// Puts the melon halfs in a place where the thrower
// can find them. In practical terms, this means
// storing the point on the melon where the slice happened.
//
// Param1 - location of the slice
//
FUNCTION(discardHalfs,
`
	CALL(putSlicedMelon)
')

//------------------------------------------------------
// This is the primary Melon Slicer loop
//------------------------------------------------------

//
// Simulates a melon slicing agent!
// Param1 - ignored
// Return - always NULL
//
FUNCTION(melonSlicerLoop,
`
  do(`

	CALL(catchMelon)
	cmpl	$0,   %eax
	jle	no_melon

	#Caught a melon! Slice it!
	CALL(sliceMelon, `%rax')
	CALL(discardHalfs, `%rax')

	no_melon:
	movq	_melonSlicerShouldStop@GOTPCREL(%rip), %rax

  ')while(`$ 0, (%rax)', je)


	#Notify done processing
	movq	_melonSlicerDidStop@GOTPCREL(%rip), %rcx
	movl	$1, (%rcx)

	xorl	%eax, %eax           #set rv to zero
')

