/* NSObject+LPDynamicIvars.h created by Lukas Pitschl (@lukele) on Wed 03-Aug-2011 */

/*
 * Copyright (c) 2000-2011, GPGToolz Project Team <gpgtoolz-devel@lists.gpgtoolz.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGToolz Project Team nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGToolz Project Team ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGToolz Project Team BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 The following methods extends every object to support additional 
 variables to be added/removed/checked at runtime.
 
 Internally uses associated objects to add this functionality.
 
 TODO: support class variables. (might work already, using objc_getClass(self))
 */
@interface NSObject (LPDynamicIvars)

/**
 Add a variable with value <value> to the object.
 */
- (void)setIvar:(id)key value:(id)value;

/**
 Add a variable with value <value> to the object.
 If shouldAssign is set to true, the value is only assigned, not retained.
 This is for example necessary under 10.7 to store a dispatch_queue_t object
 as associated object.
 */
- (void)setIvar:(id)key value:(id)value assign:(BOOL)shouldAssign;

/**
 Retrieve the value for a variable.
 */
- (id)getIvar:(id)key;
/**
 Remove an existing variable.
 */
- (void)removeIvar:(id)key;
/**
 Check if a variable is set on an object.
 */
- (BOOL)ivarExists:(id)key;

/**
 Removes every added ivar.
 */
- (void)removeIvars;

@end
