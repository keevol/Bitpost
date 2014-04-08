//
//  NavView.m
//  Bitmarket
//
//  Created by Steve Dekorte on 2/5/14.
//  Copyright (c) 2014 Bitmarkets.org. All rights reserved.
//

#import "NavView.h"
#import "NavColumn.h"
#import "NSView+sizing.h"
#import <objc/runtime.h>
#import "CustomSearchField.h"
#import "BMAddressedView.h"
#import "NSObject+extra.h"

@implementation NavView

- (BOOL)isOpaque
{
    return NO;
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    self.navColumns = [NSMutableArray array];
    self.actionStripHeight = 40.0;
    return self;
}

- (void)setRootNode:(id<NavNode>)rootNode
{
    _rootNode = rootNode;
    [self reload];
}

- (void)reload
{
    for (NavColumn *column in self.navColumns)
    {
        [column removeFromSuperview];
    }
    
    self.navColumns = [NSMutableArray array];
    
    [self addColumnForNode:self.rootNode];
}

- (NavColumn *)addColumnForNode:(id <NavNode>)node
{
    NavColumn *column = [[NavColumn alloc] initWithFrame:NSMakeRect(0, 0, 100, self.height)];
    [column setNode:node];

    NSView *lastColumn = self.navColumns.lastObject;
    [self.navColumns addObject:column];
    [self addSubview:column];

    [column setNavView:self];
    //[self stackViews];
    
    [column setHeight:self.height];
    
    if (lastColumn)
    {
        [column setX:lastColumn.x + lastColumn.width];
    }
    else
    {
        [column setX:0];
    }

    [column didAddToNavView];
    
    return column;
}

- (CGFloat)columnsWidth
{
    NSView *lastColumn = self.navColumns.lastObject;
    NSRect f = lastColumn.frame;
    return f.origin.x + f.size.width;
}

- (BOOL)shouldSelectNode:(id <NavNode>)node inColumn:inColumn
{
    NSMutableArray *toRemove = [NSMutableArray array];
    
    BOOL hitColumn = NO;
    for (NavColumn *column in self.navColumns)
    {
        if (hitColumn)
        {
            [toRemove addObject:column];
            [column removeFromSuperview];
        }
        
        if (inColumn == column)
        {
            hitColumn = YES;
        }
    }
    
    //NSLog(@"shouldSelectNode - removing old columns");
    
    [self.navColumns removeObjectsInArray:toRemove];
    
    if (node)
    {
        NavColumn *newColumn = [self addColumnForNode:node];
        [newColumn prepareToDisplay];
    }
    
    return YES;
}

- (void)clearColumns
{
    for (NavColumn *column in self.navColumns)
    {
        [column removeFromSuperview];
    }
    
    [self.navColumns removeAllObjects];
}

- (void)selectPath:(NSArray *)pathComponents
{
    NSArray *nodes = [self.rootNode nodeTitlePath:pathComponents];
    [self selectNodePath:nodes];
}

- (void)selectNodePath:(NSArray *)nodes
{
    [self clearColumns];
    
    NavColumn *column = nil;
    NavColumn *lastColumn = nil;
    
    for (id <NavNode> node in nodes)
    {
        column = [self addColumnForNode:node];
        
        if (lastColumn)
        {
            [lastColumn justSelectNode:node];
        }
        
        lastColumn = column;
    }
    
    if ([column respondsToSelector:@selector(prepareToDisplay)])
    {
        [column prepareToDisplay];
    }
}

- (NSColor *)bgColor
{
    return [Theme.sharedTheme formBackgroundColor];
}

- (NSRect)drawFrame
{
    NSRect frame = self.frame;
    frame.size.height -= self.actionStripHeight;
    return frame;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect f = self.drawFrame;
    [[self bgColor] set];
    //[[NSColor blueColor] set];
    NSRectFill(f);
    //[super drawRect:f];
}

// --- actions ---------------------------------------------------

- (BOOL)canHandleAction:(SEL)aSel
{
    id lastColumn = [self.navColumns lastObject];
    return [lastColumn canHandleAction:aSel];
}

- (void)handleAction:(SEL)aSel
{
    id lastColumn = [self.navColumns lastObject];
    [lastColumn handleAction:aSel];
}

/*
- (void)reloadedColumn:(NavColumn *)aColumn
{
    //[self updateActionStrip];
}
*/

- (id <NavNode>)lastNode
{
    NSEnumerator *e = [self.navColumns reverseObjectEnumerator];
    id column = nil;
    
    while (column = [e nextObject])
    {
        if ([column respondsToSelector:@selector(node)])
        {
            id node = [column node];
            return node;
        }
    }
    
    return nil;
}


/*
- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
    NSLog(@"class %@ got key down", NSStringFromClass([self class]));
}
*/

- (void)leftArrowFrom:aColumn
{
    NSInteger index = [self.navColumns indexOfObject:aColumn];
    
    if (index == -1 || index == 0)
    {
        return;
    }
    
    NavColumn *inColumn = [self.navColumns objectAtIndex:index - 1];
    
    [self shouldSelectNode:[inColumn selectedNode] inColumn:inColumn];
    [inColumn.window makeFirstResponder:inColumn.tableView];
//    [inColumn.tableView becomeFirstResponder];
}

- (void)rightArrowFrom:aColumn
{
    NSInteger index = [self.navColumns indexOfObject:aColumn];

    if (index == self.navColumns.count - 1)
    {
        return;
    }
    
    NavColumn *inColumn = [self.navColumns objectAtIndex:index + 1];
    
    if ([inColumn respondsToSelector:@selector(selectRowIndex:)])
    {
        [inColumn selectRowIndex:0];
        //[self shouldSelectNode:[inColumn nodeA] inColumn:inColumn];
        [inColumn.window makeFirstResponder:inColumn.tableView];
        //[inColumn.tableView becomeFirstResponder];
    }
    else if ([inColumn respondsToSelector:@selector(selectFirstResponder)])
    {
        [inColumn noWarningPerformSelector:@selector(selectFirstResponder)];
    }
}

- (NSInteger)indexOfColumn:(NavColumn *)aColumn
{
    return [self.navColumns indexOfObject:aColumn];
}

- (NavColumn *)columnForNode:(id)node
{
    for (NavColumn *column in self.navColumns)
    {
        if (column.node == node)
        {
            return column;
        }
    }
    
    return nil;
}


@end
