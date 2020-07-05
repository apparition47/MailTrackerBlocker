/* WebDocumentGenerator+GPGMail.h created by Lukas Pitschl (@lukele) on Thu 03-Apr-2014 */

/*
 * Copyright (c) 2000-2014, GPGToolz Team <team@gpgtoolz.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGToolz nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGToolz Team ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGToolz Team BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import "WebDocumentGenerator.h"

@class MUIWebDocument;

/**
 On Mavericks using the ActivityMonitor to display PGP errors when displaying
 a message in a thread does no longer work reliably.
 [[MCActivityMonitor currentMonitor] error] might return the error which belongs to the
 currently viewed message, but it might also return the error from some other message in the thread,
 depending on when the request is made and what other message is parsed in that moment.
 Mail.app creates a WebDocument for any message which is being displayed and sets the currentError
 on the WebDocument.
 In order for the WebDocument to always show the error belonging to the message being parsed,
 setWebDocument of the WebDocumentGenerator is overwritten. setWebDocument is called, when the
 message parsing has completed in is thus the right moment to overwrite the set error with the
 appropriate error.
 */
@interface WebDocumentGenerator_MailTrackerBlocker : NSObject

- (void)MASetWebDocument:(MUIWebDocument *)webDocument;

@end
