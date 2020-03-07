function NewHeap(CompareFunction)
	return {table = {}, CompareFunction = CompareFunction}
end

function PushToHeap(Heap, weight, element)
	table.insert(Heap.table, {weight, element})
	UpHeap(Heap, #Heap.table)
end

function PopFromHeap(Heap)
	ReturnedElement = Heap.table[1][2]
	Heap.table[1] = Heap.table[#Heap.table]
	table.remove(Heap.table, #Heap.table)
	
	DownHeap(Heap, 1)
	return ReturnedElement
end

function UpHeap(Heap, position)
	local parent = math.floor(position/2)
	while parent > 0 do
		if Heap.CompareFunction(Heap, position, parent) then
			SwapArrayElements(Heap.table, position, parent)
			
			position = parent
			parent = math.floor(position/2)
		else
			break
		end
	end
end

function DownHeap(Heap, position)
	while position < #Heap.table/2 do
		local child1 = 2*position
		local child2 = 2*position + 1
		
		local child1eligible = false
		if child1 <= #Heap.table then
			child1eligible = Heap.CompareFunction(Heap, child1, position)
		end
		local child2eligible = false
		if child2 <= #Heap.table then
			child2eligible = Heap.CompareFunction(Heap, child2, position)
		end
		
		if child1eligible and child2eligible then
			if Heap.CompareFunction(Heap, child2, child1) then
				SwapArrayElements(Heap.table, child2, position)
				position = child2
			else
				SwapArrayElements(Heap.table, child1, position)
				position = child1
			end
		elseif child1eligible then
			SwapArrayElements(Heap.table, child1, position)
			position = child1
		elseif child2eligible then
			SwapArrayElements(Heap.table, child2, position)
			position = child2
		else
			break
		end
	end
end

function SwapArrayElements(Table, pos1, pos2)
	local temp = Table[pos1]
	Table[pos1] = Table[pos2]
	Table[pos2] = temp
end