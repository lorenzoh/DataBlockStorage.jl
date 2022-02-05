
function savedataset!(path, storage::FileStorage, block::Keypoints, data)
    path = endswith(string(path), ".arrow") ? path : Path(string(path) * ".arrow")
    if isfile(path) && !storage.force
        error("File $path already exists. Set `storage.force` to overwrite.")
    end

    iter = if get(storage.preferences, :parallel, true)
        data -> eachobsparallel(data, buffered = false)
    else
        eachobs
    end

    obss = [obs for obs in tqdm(iter(data))]
    open(path, "w") do io
        Arrow.write(io, (data = obss,))
    end
end


function loaddataset(path, ::FileStorage, block::Keypoints{N}) where {N}
    path = endswith(string(path), ".arrow") ? path : Path(string(path) * ".arrow")
    table = Arrow.Table(path)
    return mapobs(table[:data]) do ks
        mapmaybe(k -> SVector{N}(k), ks)
    end
end


mapmaybe(f, xs) = map(x -> isnothing(x) ? nothing : f(x), xs)
