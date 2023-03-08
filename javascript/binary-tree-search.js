const Queue = require('./queueSinglyLinkedList')

class Node {
	constructor(value) {
		this.value = value
		this.left = null
		this.right = null
	}
}

class BinarySearchTree {
	constructor() {
		this.root = null
	}

	find(value) {
		function compare(value, next) {
			if (!next) {
				return false
			} else if (value === next.value) {
				return true
			} else if (value > next.value) {
				return compare(value, next.right)
			} else if (value < next.value) {
				return compare(value, next.left)
			}
		}
		return compare(value, this.root)
	}

	insert(value) {
		const newNode = new Node(value)

		if (!this.root) {
			return (this.root = newNode)
		}

		function compare(value, next) {
			if (value > next.value) {
				if (!next.right) {
					return (next.right = newNode)
				}
				return compare(value, next.right)
			} else if (value < next.value) {
				if (!next.left) {
					return (next.left = newNode)
				}
				return compare(value, next.left)
			}
		}

		return compare(value, this.root)
	}

	searchBreadth() {
		const queue = new Queue()
		let values = []
		const root = this.root

		function search(node) {
			if (!node) {
				queue.enqueue(root)
			}

			if (node && node.left) {
				queue.enqueue(node.left)
			}

			if (node && node.right) {
				queue.enqueue(node.right)
			}

			while (queue.length) {
				const _node = queue.dequeue()
				values.push(_node.value.value)
				search(_node.value)
			}
		}
		search()
		return values
	}

	searchDepth(preOrder = true, inOrder = false) {
		const values = []

		function traverse(node) {
			preOrder && !inOrder && values.push(node.value)

			if (node.left) {
				traverse(node.left)
			}

			inOrder && values.push(node.value)

			if (node.right) {
				traverse(node.right)
			}

			!preOrder && !inOrder && values.push(node.value)
		}

		traverse(this.root)

		return values
	}
}

const tree = new BinarySearchTree()
tree.insert(10)
tree.insert(14)
tree.insert(15)
tree.insert(16)
tree.insert(6)
tree.insert(7)
tree.insert(8)
tree.insert(24)
tree.insert(11)
tree.insert(1)
tree.insert(2)

// Our tree:
//                        10
//          6                        14
//   1          7                11      15
//      2           8                        16
//                                               24

const search1 = tree.searchBreadth()
console.log(search1)
// 10, 6, 14, 1, 7, 11, 15, 2, 8, 16, 24

const search2 = tree.searchDepth()
console.log(search2)
// 10, 6, 1, 2, 7, 8, 14, 11, 15, 16, 24

const search3 = tree.searchDepth(false)
console.log(search3)
// 2, 1, 8, 7, 6, 11, 24, 16, 15, 14, 10

const search4 = tree.searchDepth(false, true)
console.log(search4)
// 1, 2, 6, 7, 8, 10, 11, 14, 15, 16, 24
