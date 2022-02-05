
struct FileStorage <: DataStorage
    path::Any
    verbose::Any
    force::Any
    preferences::Any
end

FileStorage(path; verbose = true, force = false, kwargs...) =
    FileStorage(path, verbose, force, Dict(kwargs...))

gethandle(storage::FileStorage) = joinpath(storage.path, "data")

function savemetadata(storage::FileStorage, metadata)
    file = string(joinpath(storage.path, "meta.jld2"))
    JLD2.save(file, metadata)
end

function loadmetadata(storage::FileStorage)
    JLD2.load(string(joinpath(storage.path, "meta.jld2")))
end

function savedataset!(path, storage::FileStorage, blocks::Tuple, datas::Tuple)
    ensuredir(storage, path)
    for (i, (block, data)) in enumerate(zip(blocks, datas))
        subpath = joinpath(path, "block_$(lpad(i, 4, '0'))")
        savedataset!(subpath, storage, block, data)
    end
end

function savedataset!(path, storage::FileStorage, blocks::Tuple, datas)
    ensuredir(storage, path)
    for (i, block) in enumerate(blocks)
        data = mapobs(obs -> obs[i], datas)
        subpath = joinpath(path, "block_$(lpad(i, 4, '0'))")
        savedataset!(subpath, storage, block, data)
    end
end

function ensuredir(storage::FileStorage, path)
    if isdir(path) || isfile(path)
        if storage.force
            rm(path, recursive = true)
        else
            error("Directory $path already exists, aborting.")
        end
    end
    mkdir(path)
end


function loaddataset(path, storage::FileStorage, blocks::Tuple)
    datas = []
    for (i, block) in enumerate(blocks)
        subpath = joinpath(path, "block_$(lpad(i, 4, '0'))")
        data = loaddataset(subpath, storage, block)
        push!(datas, data)
    end
    return Tuple(datas)
end
