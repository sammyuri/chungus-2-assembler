from nbt import nbt
from typing import List

SCHEM_MAX_SIZE = 1024


def generate_block_data(assembly: List[str], blankschem):
    def create_barrel(pos: List[int], ss: int) -> nbt.TAG_Compound:
        barrel = nbt.TAG_Compound(name="")
        barrel.tags.append(nbt.TAG_Int_Array(name="Pos"))
        barrel["Pos"].value = pos.copy()
        itemslist = nbt.TAG_List(name="Items", type=nbt.TAG_Compound)

        for count in range(
            min(27, (max(64 * ss, int((27 * 64 / 14) * (ss - 1)) + 63)) // 64)
        ):
            item = nbt.TAG_Compound(name="")
            item.tags.append(nbt.TAG_Byte(
                name="Slot",
                value=count
            ))
            item.tags.append(nbt.TAG_String(
                name="id",
                value="minecraft:redstone"
            ))
            item.tags.append(nbt.TAG_Byte(
                name="Count",
                value=64
            ))
            itemslist.tags.append(item)

        barrel.tags.append(itemslist)
        barrel.tags.append(nbt.TAG_String(name="Id", value="minecraft:barrel"))
        return barrel

    basedata = bytearray(blankschem["BlockData"].value)
    blockentities = nbt.TAG_List(name="BlockEntities", type=nbt.TAG_Compound)
    assembly.extend(
        ["0000000000000000" for i in range(SCHEM_MAX_SIZE - len(assembly))]
    )

    for instruction in range(256):
        ilist = [
            assembly[64 * (instruction // 16) + instruction % 16],
            assembly[64 * (instruction // 16) + instruction % 16 + 16],
            assembly[64 * (instruction // 16) + instruction % 16 + 32],
            assembly[64 * (instruction // 16) + instruction % 16 + 48],
        ]
        for bit in range(16):
            x = 4 * (instruction // 16)
            if bit > 7 and instruction % 32 < 16:
                x += 2
            if bit < 8 and instruction % 32 > 15:
                x += 2
            y = 15 - ((2 * bit) % 16 + (1 if instruction % 2 == 0 else 0))
            z = 30 - (2 * (instruction % 16))
            absolute = x + 63 * z + 31 * 63 * y
            ss = 15 - (
                int(ilist[0][bit])
                + int(ilist[1][bit]) * 2
                + int(ilist[2][bit]) * 4
                + int(ilist[3][bit]) * 8
            )
            if ss == 0:
                basedata[absolute] = 3
            elif ss != 15:
                blockentities.tags.append(create_barrel([x, y, z], ss))
                basedata[absolute] = 2
    return basedata, blockentities


def generate_schematic(assembly: List[str], name: str = "output") -> None:
    blankschem = nbt.NBTFile("ROM_blank.schem", "rb")

    nbtfile = nbt.NBTFile()
    nbtfile.name = "Schematic"

    nbtfile.tags.append(nbt.TAG_Int(name="PaletteMax", value=4))
    palette = nbt.TAG_Compound(name="Palette")
    palette.tags.append(nbt.TAG_Int(name="minecraft:air", value=0))
    palette.tags.append(nbt.TAG_Int(name="minecraft:redstone_block", value=1))
    palette.tags.append(nbt.TAG_Int(name="minecraft:barrel", value=2))
    palette.tags.append(nbt.TAG_Int(name="minecraft:stone", value=3))
    palette.name = "Palette"
    nbtfile.tags.append(palette)

    nbtfile.tags.extend([
        nbt.TAG_Int(name="DataVersion", value=blankschem["DataVersion"].value),
        nbt.TAG_Int(name="Version", value=blankschem["Version"].value),
        nbt.TAG_Short(name="Length", value=blankschem["Length"].value),
        nbt.TAG_Short(name="Height", value=blankschem["Height"].value),
        nbt.TAG_Short(name="Width", value=blankschem["Width"].value),
        nbt.TAG_Int_Array(name="Offset"),
    ])
    nbtfile["Offset"].value = blankschem["Offset"].value
    metadata = nbt.TAG_Compound()
    metadata.tags = blankschem["Metadata"].tags.copy()
    metadata.name = "Metadata"
    nbtfile.tags.append(metadata)

    basedata, blockentities = generate_block_data(assembly, blankschem)
    nbtfile.tags.append(nbt.TAG_Byte_Array(name="BlockData"))
    nbtfile["BlockData"].value = basedata
    nbtfile.tags.append(blockentities)

    nbtfile.write_file(f"{name}.schem")
