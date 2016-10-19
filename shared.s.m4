include(macroLibrary.m4)

	.section __CODE__

//
// Returns a random integer between param1
// and param2 inclusive
// param1 - start of range
// param2 - end of range
// return - integer
//
FUNCTION(randomInterval,
`
	#     x64 arithmetic is a pain.       #
	#     Power is less of a strain.      #
	#       here is the equation:         #
	# ( random() % (end-start) ) + start  #
	movl	%edi, %r12d
	movl	%esi, %r13d
	CALL(random)
	movl	%r13d, %esi
	subl	%r12d, %esi
	movslq	%esi, %rcx
	cqto
	idivq	%rcx
	movslq	%r12d, %rcx
	addq	%rcx, %rdx
	movl	%edx, %eax
')

//-------------------------------------------------------------
// Functions that need locks
//-------------------------------------------------------------

//
// This function protects the _rawMelon variable.
//
// Deadlock prevention:
// We know there is no deadlock because the code
// see that no other locks are acquired after this
// lock is acquired. Coffman condition 4.
//
// Race condition prevention:
// Visually inspect that the rawMelon variable is
// only accessed when the rawMutex is held.
//
// Param1 - becomes new value of rawMelon
//
FUNCTION(putRawMelon,
`	movl	%edi, %r12d

	LOCK(rawMutex)

	movl	%r12d, _rawMelon(%rip)

	UNLOCK(rawMutex)
')

//
// Retrieves value stored in _rawMelon,
// and resets it to -1
// Return - The value that was stored in _rawMelon
//
FUNCTION(getRawMelon,
`
	LOCK(rawMutex)

	movl	_rawMelon(%rip), %r12d
	movl	$-1, _rawMelon(%rip)

	UNLOCK(rawMutex)

	movl	%r12d, %eax
')

FUNCTION(putSlicedMelon,
`
	movl	%edi, %r12d

	LOCK(slicedMutex)
	
	movl	%r12d, _slicedMelonLocation(%rip)

	UNLOCK(slicedMutex)
')

FUNCTION(getSlicedMelon,
`
	LOCK(slicedMutex)

	movl	_slicedMelonLocation(%rip), %r12d
	movl	$-1, _slicedMelonLocation(%rip)

	UNLOCK(slicedMutex)

	movl	%r12d, %eax
')

//----------------------------------------------------------
// Shared variables
//----------------------------------------------------------
	.section	__DATA,__data
	.globl	_rawMelon
	.align	2
_rawMelon:
	.long	4294967295              ## 0xffffffff

	.comm	_rawMutex,64,3
	.globl	_slicedMelonLocation
	.align	2
_slicedMelonLocation:
	.long	4294967295              ## 0xffffffff

	.comm	_slicedMutex,64,3
	.comm	_melonThrowerShouldStop,4,2
	.comm	_melonSlicerShouldStop,4,2
	.comm	_melonThrowerDidStop,4,2
	.comm	_melonSlicerDidStop,4,2
	.comm	_slicerThread,8,3
	.comm	_throwerThread,8,3

//----------------------------------------------------------
// The End.
//----------------------------------------------------------
