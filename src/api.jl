
abstract type DataStorage end


"""
    savedataset(::DataStorage, blocks, data)

Save a data container `data` with sample blocks `blocks` to a storage.
along with metadata on the dataset.
"""
function savedataset(storage::DataStorage, block, data)
    savemetadata(storage, getmetadata(block, data))
    savedataset!(gethandle(storage), storage, block, data)
end

getmetadata(block, data) = Dict("block" => block, "n" => nobs(data))

"""
    savedataset!(handle, ::DataStorage, block, data)

Save a `block` of `data` to a storage's  `handle`.
"""
function savedataset! end

savedataset!(handle, storage, block::FastAI.WrapperBlock, data) =
    savedataset!(handle, storage, FastAI.wrapped(block), data)
"""
    savemetadata(::DataStorage, blocks, data)
"""
function savemetadata end
function loadmetadata end

function gethandle end

"""
    loaddataset(::DataStorage) -> (data, blocks)

Load a dataset
"""
function loaddataset(storage::DataStorage)
    metadata = loadmetadata(storage)
    block = metadata["block"]
    data = loaddataset(gethandle(storage), storage, block)
    return data, block
end

loaddataset(handle, storage, block::FastAI.WrapperBlock) =
    loaddataset(handle, storage, FastAI.wrapped(block))
