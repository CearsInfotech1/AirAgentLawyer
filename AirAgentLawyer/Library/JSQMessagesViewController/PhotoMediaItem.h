//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "JSQMediaItem.h"


#define		STATUS_LOADING						1
#define		STATUS_FAILED						2
#define		STATUS_SUCCEED						3

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface PhotoMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (nonatomic, assign) int status;

@property (copy, nonatomic) UIImage *image;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;

- (instancetype)initWithImage:(UIImage *)image Width:(NSNumber *)width Height:(NSNumber *)height;

@end

