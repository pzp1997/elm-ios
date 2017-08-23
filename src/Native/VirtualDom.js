var _elm_lang$virtual_dom$Native_VirtualDom = function() {

  var YOGA_KEY = 'YOGA';
  var EVENT_KEY = 'EVENT';

  ////////////  EVENT REGISTRY  ////////////

  var nextEventId = 0;
  var eventRegistry = _elm_lang$core$Dict$empty;

  ////////////  NODES  ////////////

  function leaf(tag, factList) {
    return {
      type: 'leaf',
      tag: tag,
      facts: organizeFacts(factList)
    };
  }

  function parent(factList, kidList) {
    var children = [];
    var descendantsCount = 0;
    while (kidList.ctor !== '[]') {
      var kid = kidList._0;
      descendantsCount += (kid.descendantsCount || 0);
      children.push(kid);
      kidList = kidList._1;
    }
    descendantsCount += children.length;

    return {
      type: 'parent',
      facts: organizeFacts(factList),
      children: children,
      descendantsCount: descendantsCount
    };
  }

  function map(tagger, node) {
    return {
      type: 'tagger',
      tagger: tagger,
      node: node,
      descendantsCount: (node.descendantsCount || 0) + 1
    };
  }

  function thunk(func, args, thunk) {
    return {
      type: 'thunk',
      func: func,
      args: args,
      thunk: thunk,
      node: undefined,
      descendantsCount: 0 // eventually will be node.descendantsCount || 0
    };
  }

  function lazy(fn, a) {
    return thunk(fn, [a], function() {
      return fn(a);
    });
  }

  function lazy2(fn, a, b) {
    return thunk(fn, [a, b], function() {
      return A2(fn, a, b);
    });
  }

  function lazy3(fn, a, b, c) {
    return thunk(fn, [a, b, c], function() {
      return A3(fn, a, b, c);
    });
  }


  ////////////  FACTS  ////////////


  function organizeFacts(factList) {
    var facts = {};

    while (factList.ctor !== '[]') {
      var entry = factList._0;
      var key = entry.key;

      if (key == YOGA_KEY || key === EVENT_KEY) {
        var subFacts = facts[key] || {};
        subFacts[entry.realKey] = entry.value;
        facts[key] = subFacts;
      } else {
        facts[key] = entry.value;
      }

      factList = factList._1;
    }

    return facts;
  }


  ////////////  PROPERTIES  ////////////


  function property(key, value) {
    return {
      key: key,
      value: value
    };
  }

  function yogaProperty(key, value) {
    return {
      key: YOGA_KEY,
      realKey: key,
      value: value
    };
  }

  function on(name, decoder) {
    return {
      key: EVENT_KEY,
      realKey: name,
      value: decoder
    };
  }

  function mapProperty(func, property) {
    if (property.key !== EVENT_KEY) {
      return property;
    }
    return on(
      property.realKey,
      A2(_elm_lang$core$Json_Decode$map, func, property.value)
    );
  }


  ////////////  PATCHES  ////////////


  function makeChangePatch(type, data) {
    return {
      ctor: 'change',
      type: type,
      data: data
    };
  }

  function makeAtPatch(index, patch) {
    return {
      ctor: 'at',
      index: index,
      patch: patch
    };
  }

  function makeBatchPatch(patches) {
    return {
      ctor: 'batch',
      patches: patches
    }
  }

  function combinePatches(newPatch, maybeBatchPatch) {
    if (typeof maybeBatchPatch !== 'undefined') {
      if (maybeBatchPatch.ctor !== 'batch') {
        return makeBatchPatch([maybeBatchPatch, newPatch]);
      } else {
        maybeBatchPatch.patches.push(newPatch);
        return maybeBatchPatch;
      }
    } else {
      return newPatch;
    }
  }

  function renderData(vNode, handlerList, offset) {
    return {
      vNode: vNode,
      handlerList: handlerList,
      offset: offset
    };
  }


  ////////////  DIFF  ////////////


  function diff(a, b, aOffset, bOffset, dominatingTagger, eventList) {
    if (a === b) {
      return;
    }

    var thisOffset = bOffset.value;

    var aType = a.type;
    var bType = b.type;

    if (aType !== bType) {
      if (aType === 'tagger') {
        // REMOVING A TAGGER
        // 1. Remove the next item from the eventList but do not move the cursor.
        // 2. Continue diffing with the dominatingTagger.

        removeNext(eventList);
        return diff(a.node, b, aOffset + 1, bOffset, dominatingTagger, eventList);
      } else if (bType === 'tagger') {
        // ADDING A TAGGER
        // 1. Create the new tagger with dominatingTagger as the parent.
        // 2. Insert it after the cursor and move the cursor forward.
        // 3. Continue diffing with the newTagger as the dominatingTagger.
        // 4. Update b.descendantsCount.

        // create the new tagger
        var newTagger = makeTaggerNode(b.tagger, thisOffset);
        newTagger.parent = dominatingTagger;

        // insert newTagger into the correct position in eventList
        insertAfterCursor(newTagger, eventList);

        bOffset.value++;
        var patch = diff(a, b.node, aOffset, bOffset, newTagger, eventList);

        b.descendantsCount = bOffset.value - thisOffset;
        return patch;
      } else {
        // REDRAW
        // 1. prerender the node.
        // 2. Update b.descendantsCount.
        // 3. Remove the extra taggers and handlers.
        //    (a) removeUntilOffset with aOffset + (a.descendantsCount || 0)
        // 4. Make a redraw patch.

        // Redraw the node.
        var partialHandlerList = [];
        prerender(b, bOffset, dominatingTagger, eventList, partialHandlerList);

        b.descendantsCount = bOffset.value - thisOffset;

        // Remove the extra taggers and handlers
        removeUntilOffset(aOffset + (a.descendantsCount || 0), eventList);

        return makeChangePatch(
          'redraw', renderData(b, partialHandlerList, thisOffset));
      }
    }

    // Now we know that both nodes are the same type.
    switch (bType) {
      case 'thunk':
        if (a.func === b.func && equalArrays(a.args, b.args)) {
          // skip over cached items in eventList and update their offsets
          var deltaOffset = thisOffset - aOffset;

          var descendantsCount = a.descendantsCount;
          var lastOffset = aOffset + descendantsCount;

          var node = eventList.cursor;
          var next;
          while (typeof(next = node.next) !== 'undefined' && next.offset <= lastOffset) {
            node.offset += deltaOffset;
            node = next;
          }
          eventList.cursor = node;

          // update bOffset with the number of nodes we skipped over
          bOffset.value += descendantsCount;

          // copy over the actual node and descendantsCount
          b.node = a.node;
          b.descendantsCount = descendantsCount;
          return;
        }

        b.node = b.thunk();
        var patch = diff(
          a.node, b.node, aOffset, bOffset, dominatingTagger, eventList);

        b.descendantsCount = bOffset.value - thisOffset;

        return patch;

      case 'tagger':
        // NEXT TAGGER
        // 1. Move the cursor forward to nextTagger.
        // 2. Update the func, offset, parent of nextTagger.
        // 3. Continue diffing with the nextTagger as the dominatingTagger
        // 4. Update b.descendantsCount.

        var nextTagger = moveCursorForward(eventList);

        // update the fields of nextTagger
        nextTagger.func = b.tagger;
        nextTagger.offset = thisOffset;
        nextTagger.parent = dominatingTagger;

        bOffset.value++;
        var patch = diff(
          a.node, b.node, aOffset + 1, bOffset, nextTagger, eventList);

        b.descendantsCount = bOffset.value - thisOffset;

        return patch;

      case 'leaf':
        var bTag = b.tag;

        if (a.tag !== bTag) {
          // REDRAW OF LEAF
          // 1. addHandlerNode on the node (since leaf does not have children,
          // this is faster than calling prerender).
          // 2. Remove the extra handler, if it exists.
          // 3. Make a redraw patch.

          var partialHandlerList = [];
          var handlers = b.facts[EVENT_KEY];
          if (typeof handlers !== 'undefined') {
            partialHandlerList.push(addHandlerNode(
              handlers, thisOffset, dominatingTagger, eventList));
          }

          removeUntilOffset(aOffset, eventList);

          return makeChangePatch(
            'redraw', renderData(b, partialHandlerList, thisOffset));
        }

        var patch = updateHandlerNode(
          a.facts[EVENT_KEY], b.facts[EVENT_KEY], thisOffset, dominatingTagger, eventList);

        var factsDiff = diffFacts(a.facts, b.facts);
        if (typeof factsDiff !== 'undefined') {
          factsDiff.tag = bTag;
          patch = combinePatches(makeChangePatch('facts', factsDiff), patch);
        }

        return patch;

      case 'parent':
        var patch;

        // We can comment this out for now since only leaves have handlers.
        // var patch = updateHandlerNode(
        //   a.facts[EVENT_KEY], b.facts[EVENT_KEY], thisOffset, dominatingTagger, eventList);

        var factsDiff = diffFacts(a.facts, b.facts);
        if (typeof factsDiff !== 'undefined') {
          factsDiff.tag = 'parent';
          patch = makeChangePatch('facts', factsDiff);
        }

        patch = diffChildren(
          a, b, patch, aOffset, bOffset, dominatingTagger, eventList);

        b.descendantsCount = bOffset.value - thisOffset;

        return patch;
    }
  }

  function equalArrays(a, b) {
    if (a === b) {
      return true;
    }
    var len = a.length;
    if (len !== b.length) {
      return false;
    }
    for (var i = 0; i < len; i++) {
      if (a[i] !== b[i]) {
        return false;
      }
    }
    return true;
  }

  function updateHandlerNode(aHandlers, bHandlers, offset, dominatingTagger, eventList) {
    // Deal with cases where handlers are only on the old or new node
    if (typeof aHandlers !== 'undefined') {
      if (typeof bHandlers === 'undefined') {
        var removedHandlerNode = removeNext(eventList);
        eventRegistry = A2(
          _elm_lang$core$Dict$remove, removedHandlerNode.eventId, eventRegistry);
        return makeChangePatch('remove-all-handlers', undefined);
      }
    } else if (typeof bHandlers !== 'undefined') {
      return makeChangePatch(
        'add-handlers', addHandlerNode(bHandlers, offset, dominatingTagger, eventList));
    } else {
      return;
    }

    var cursor = moveCursorForward(eventList);

    // update the cursor's offset and parent
    cursor.offset = offset;
    cursor.parent = dominatingTagger;

    var patch;

    // find any handlers that were removed
    var removedHandlers = [];
    for (var aName in aHandlers) {
      if (!(aName in bHandlers)) {
        removedHandlers.push(aName);
        cursor.funcs[aName] = undefined;
      }
    }

    if (removedHandlers.length > 0) {
      patch = makeChangePatch('remove-handlers', removedHandlers);
    }

    // find any handlers that were added and update funcs of existing handlers
    var addedHandlers = {};
    var didAddHandlers = false;
    for (var bName in bHandlers) {
      var bFunc = bHandlers[bName];
      if (!(bName in aHandlers)) {
        addedHandlers[bName] = bFunc;
        didAddHandlers = true;
      }
      cursor.funcs[bName] = bFunc;
    }

    if (didAddHandlers) {
      patch = combinePatches(makeChangePatch('add-handlers',
        makeSwiftHandlerNode(cursor.eventId, addedHandlers, offset)), patch);
    }

    return patch;
  }


  function diffFacts(a, b, category) {
    var diff;

    // look for changes and removals
    for (var aKey in a) {
      if (aKey === EVENT_KEY) {
        continue;
      }

      if (aKey === YOGA_KEY) {
        var subDiff = diffFacts(a[aKey], b[aKey] || {}, aKey);
        if (subDiff) {
          diff = diff || {};
          diff[aKey] = subDiff;
        }
        continue;
      }

      if (!(aKey in b)) {
        diff = diff || {};
        // the below must be null, not undefined. this is because undefined
        // gets converted to nil in Swift, which causes the key to not be in
        // the Swift Dict when the facts diff crosses the bridge.
        diff[aKey] = null;
        continue;
      }

      var aValue = a[aKey];
      var bValue = b[aKey];

      // reference equal, so don't worry about it
      if (aValue === bValue ||
        ((aKey === 'textColor' || aKey === 'backgroundColor' ||
            aKey === 'shadowColor' || aKey === 'shadowOffset') &&
          equalArrays(aValue, bValue))) {
        continue;
      }

      diff = diff || {};
      diff[aKey] = bValue;
    }

    // add new stuff
    for (var bKey in b) {
      if (bKey === EVENT_KEY) {
        continue;
      }

      if (!(bKey in a)) {
        diff = diff || {};
        diff[bKey] = b[bKey];
      }
    }

    return diff;
  }


  function diffChildren(aParent, bParent, patch, aOffset, bOffset, dominatingTagger, eventList) {
    var thisOffset = bOffset.value;

    var aChildren = aParent.children;
    var bChildren = bParent.children;

    var aLen = aChildren.length;
    var bLen = bChildren.length;

    // PAIRWISE DIFF EVERYTHING ELSE

    var minLen = aLen < bLen ? aLen : bLen;
    for (var i = 0; i < minLen; i++) {
      var aChild = aChildren[i];

      bOffset.value++;
      var childPatch = diff(
        aChild, bChildren[i], ++aOffset, bOffset, dominatingTagger, eventList);

      if (typeof childPatch !== 'undefined') {
        patch = combinePatches(makeAtPatch(i, childPatch), patch);
      }

      aOffset += aChild.descendantsCount || 0;
    }

    // FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

    if (aLen > bLen) {
      patch = combinePatches(makeChangePatch('remove-last', aLen - bLen), patch);
    } else if (aLen < bLen) {
      var newChildren = bChildren.slice(aLen);
      var partialHandlerList = [];
      for (var i = 0; i < newChildren.length; i++) {
        bOffset.value++;
        prerender(
          newChildren[i], bOffset, dominatingTagger, eventList, partialHandlerList);
      }

      // Construct the append patch
      patch = combinePatches(makeChangePatch('append', renderData(
        newChildren, partialHandlerList, thisOffset)), patch);
    }

    bParent.descendantsCount = bOffset.value - thisOffset;

    return patch;
  }


  ////////////  CURSOR LIST  ////////////


  function makeCursorList(head) {
    return {
      head: head,
      cursor: head
    };
  }

  function removeUntilOffset(offset, list) {
    var node = list.cursor.next;
    while (typeof node !== 'undefined' && node.offset <= offset) {
      node = node.next;
    }
    list.cursor.next = node;
  }

  function insertAfterCursor(item, list) {
    // no need to check for undefined, the head is always rootEventNode
    item.next = list.cursor.next;
    list.cursor.next = item;
    list.cursor = item;
  }

  function moveCursorForward(list) {
    return list.cursor = list.cursor.next;
  }

  function removeNext(list) {
    var removed = list.cursor.next;
    list.cursor.next = removed.next;
    return removed;
  }


  ////////////  EVENT NODES  ////////////


  function makeTaggerNode(func, offset) {
    return {
      func: func,
      offset: offset,
      parent: undefined,
      next: undefined
    }
  }

  function makeHandlerNode(eventId, initialFuncs, offset, parent) {
    return {
      eventId: eventId,
      funcs: initialFuncs,
      offset: offset,
      parent: parent,
      next: undefined
    };
  }

  function makeSwiftHandlerNode(eventId, funcs, offset) {
    return {
      eventId: eventId,
      funcs: funcs,
      offset: offset
    };
  }

  function addHandlerNode(handlers, offset, dominatingTagger, eventList) {
    var eventId = nextEventId++;
    var newHandlerNode = makeHandlerNode(
      eventId, handlers, offset, dominatingTagger);
    eventRegistry = A3(
      _elm_lang$core$Dict$insert, eventId, newHandlerNode, eventRegistry);
    insertAfterCursor(newHandlerNode, eventList);
    return makeSwiftHandlerNode(eventId, handlers, offset);
  }

  function makeRef(x) {
    return {
      value: x
    };
  }


  ////////////  PRERENDER  ////////////

  function prerender(vNode, offset, dominatingTagger, eventList, handlerList) {
    var thisOffset = offset.value;

    switch (vNode.type) {
      case 'thunk':
        if (!vNode.node) {
          vNode.node = vNode.thunk();
        }
        prerender(vNode.node, offset, dominatingTagger, eventList, handlerList);
        vNode.descendantsCount = offset.value - thisOffset;
        return;

      case 'tagger':
        // create the new tagger
        var newTagger = makeTaggerNode(vNode.tagger, thisOffset);
        newTagger.parent = dominatingTagger;

        // insert newTagger into the correct position in eventList
        insertAfterCursor(newTagger, eventList);

        offset.value++;
        prerender(vNode.node, offset, newTagger, eventList, handlerList);
        vNode.descendantsCount = offset.value - thisOffset;
        return;

      case 'leaf':
        var handlers = vNode.facts[EVENT_KEY];
        if (typeof handlers !== 'undefined') {
          handlerList.push(
            addHandlerNode(handlers, thisOffset, dominatingTagger, eventList));
        }
        return;

      case 'parent':
        // We can comment this out for now since only leaves have handlers.
        // var handlers = vNode.facts[EVENT_KEY];
        // if (typeof handlers !== 'undefined') {
        //   handlerList.push(
        //     addHandlerNode(handlers, thisOffset, dominatingTagger, eventList));
        // }

        var children = vNode.children;
        for (var i = 0; i < children.length; i++) {
          offset.value++;
          prerender(
            children[i], offset, dominatingTagger, eventList, handlerList);
        }
        vNode.descendantsCount = offset.value - thisOffset;
        return;
    }
  }


  ////////////  PROGRAMS  ////////////


  function program(impl) {
    return function(flagDecoder) {
      return function(object, moduleName) {
        normalSetup(impl, object);
      };
    };
  }

  function staticProgram(vNode) {
    var nothing = _elm_lang$core$Native_Utils.Tuple2(
      _elm_lang$core$Native_Utils.Tuple0,
      _elm_lang$core$Platform_Cmd$none
    );
    return program({
      init: nothing,
      view: function() {
        return vNode;
      },
      update: F2(function() {
        return nothing;
      }),
      subscriptions: function() {
        return _elm_lang$core$Platform_Sub$none;
      }
    })();
  }

  //  NORMAL SETUP

  function normalSetup(impl, object) {
    object['start'] = function start(flags) {
      if (typeof flags !== 'undefined') {
        throw new Error(
          'The `' + moduleName + '` module does not need flags.\n' +
          'Initialize it with no arguments and you should be all set!');
      }

      return _elm_lang$core$Native_Platform.initialize(
        impl.init,
        impl.update,
        impl.subscriptions,
        normalRenderer(impl.view)
      );
    };

    object['handleEvent'] = function handleEvent(id, name, data) {
      var handlerNode = A2(_elm_lang$core$Dict$get, id, eventRegistry);
      if (handlerNode.ctor !== 'Just') {
        return;
      }
      handlerNode = handlerNode._0;

      var result = A2(
        _elm_lang$core$Native_Json.run, handlerNode.funcs[name], data);
      if (result.ctor === 'Ok') {
        var result = result._0;
        var node = handlerNode.parent;
        while (typeof node !== 'undefined') {
          result = node.func(result);
          node = node.parent;
        }
      }
    };
  }

  function normalRenderer(view) {
    return function(tagger, initialModel) {
      var currNode = view(initialModel);

      var rootEventNode = makeTaggerNode(tagger, 0);
      var eventList = makeCursorList(rootEventNode);

      var initialHandlerList = [];
      prerender(
        currNode, makeRef(0), rootEventNode, eventList, initialHandlerList);

      // exposed by JSCore
      initialRender(currNode, initialHandlerList);

      // called by runtime every time model changes
      return function stepper(model) {
        var nextNode = view(model);

        eventList.cursor = rootEventNode;
        var patches = diff(
          currNode, nextNode, 0, makeRef(0), rootEventNode, eventList);

        // prevent the eventIds from overflowing by doing a full redraw
        if (nextEventId > Number.MAX_SAFE_INTEGER) {
          nextEventId = 0;
          eventRegistry = _elm_lang$core$Dict$empty;

          eventList = makeCursorList(rootEventNode);

          var handlerList = [];
          prerender(
            nextNode, makeRef(0), rootEventNode, eventList, handlerList);

          patches = makeChangePatch(
            'redraw', renderData(nextNode, handlerList, 0));
        }

        if (typeof patches !== 'undefined') {
          // exposed by JSCore
          applyPatches(patches);
        }
        currNode = nextNode;
      };
    };
  }

  return {
    parent: F2(parent),
    leaf: F2(leaf),
    map: F2(map),

    on: F2(on),
    property: F2(property),
    yogaProperty: F2(yogaProperty),
    mapProperty: F2(mapProperty),

    lazy: F2(lazy),
    lazy2: F3(lazy2),
    lazy3: F4(lazy3),

    program: program,
    staticProgram: staticProgram
  };

}();
