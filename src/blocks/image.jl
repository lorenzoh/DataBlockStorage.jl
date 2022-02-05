
function savedataset!(path, storage::FileStorage, block::Image{2}, data)
    ensuredir(storage, path)

    # Create saving jobs
    npad = ceil(Int, log10(nobs(data)))
    savejobs = mapobs(1:nobs(data)) do i
        img = getobs(data, i)
        ext = get(storage.preferences, :imageformat, "jpg")
        filename = "$(lpad(string(i), npad, "0")).$(ext)"
        save(string(joinpath(path, filename)), img)
        return "Done"
    end

    # Run export
    progress = Progress(
        nobs(data),
        enabled = storage.verbose,
        desc = "Writing images: ",
        showspeed = true,
    )
    iter = if get(storage.preferences, :parallel, true)
        data -> eachobsparallel(data, buffered = false)
    else
        eachobs
    end
    for res in iter(savejobs)
        next!(progress)
    end
end


function loaddataset(path, ::FileStorage, ::Image{2})
    return mapobs(loadfile, FileDataset(path))
end
