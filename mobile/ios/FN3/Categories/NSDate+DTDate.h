//
//  NSDate+DTDate.h
//  FN3
//
//  Created by David Jablonski on 3/8/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//



@interface NSDate (DTDate)

+ (NSDate *)dateFromParsingMessageString:(NSString *)string;

/*
 * Converts the NSDate to the specified format.
 *
 * %a is replaced by the locale's abbreviated weekday name.
 * %A is replaced by the locale's full weekday name.
 * %b is replaced by the locale's abbreviated month name.
 * %B is replaced by the locale's full month name.
 * %c is replaced by the locale's appropriate date and time representation.
 * %C is replaced by the century number (the year divided by 100 and truncated to an integer) as a decimal number [00-99].
 * %d is replaced by the day of the month as a decimal number [01,31].
 * %D same as %m/%d/%y.
 * %e is replaced by the day of the month as a decimal number [1,31]; a single digit is preceded by a space.
 * %h same as %b.
 * %H is replaced by the hour (24-hour clock) as a decimal number [00,23].
 * %I is replaced by the hour (12-hour clock) as a decimal number [01,12].
 * %j is replaced by the day of the year as a decimal number [001,366].
 * %m is replaced by the month as a decimal number [01,12].
 * %M is replaced by the minute as a decimal number [00,59].
 * %n is replaced by a newline character.
 * %p is replaced by the locale's equivalent of either a.m. or p.m.
 * %r is replaced by the time in a.m. and p.m. notation; in the POSIX locale this is equivalent to %I:%M:%S %p.
 * %R is replaced by the time in 24 hour notation (%H:%M).
 * %S is replaced by the second as a decimal number [00,61].
 * %t is replaced by a tab character.
 * %T is replaced by the time (%H:%M:%S).
 * %u is replaced by the weekday as a decimal number [1,7], with 1 representing Monday.
 * %U is replaced by the week number of the year (Sunday as the first day of the week) as a decimal number [00,53].
 * %V is replaced by the week number of the year (Monday as the first day of the week) as a decimal number [01,53]. If the week containing 1 January has four or more days in the new year, then it is considered week 1. Otherwise, it is the last week of the previous year, and the next week is week 1.
 * %w is replaced by the weekday as a decimal number [0,6], with 0 representing Sunday.
 * %W is replaced by the week number of the year (Monday as the first day of the week) as a decimal number [00,53]. All days in a new year preceding the first Monday are considered to be in week 0.
 * %x is replaced by the locale's appropriate date representation.
 * %X is replaced by the locale's appropriate time representation.
 * %y is replaced by the year without century as a decimal number [00,99].
 * %Y is replaced by the year with century as a decimal number.
 * %Z is replaced by the timezone name or abbreviation, or by no bytes if no timezone information exists.
 * %% is replaced by %.
 */
- (NSString*) toFormattedString:(NSString*)format;

- (NSString*) toFormattedString:(NSString*)format timeZone:(NSTimeZone *)tz;

/*
 * Converts the NSDate to an NSString in the specified format using UTC time.
 * See toFormattedString() for format conversions.
 */
- (NSString*) toGMFormattedString:(NSString*)format;

@end
