/*
 * IRWMMeshData.cs
 *
 * Description: Simple interface to define required properties of MeshData country classes.
 * 
 * Supported Unity version: 2020.2.1f1Personal (tested)
 *
 * Author: Nico Reski
 * Web: https://reski.nicoversity.com
 * Twitter: @nicoversity
 * GitHub: https://github.com/nicoversity
 * 
 */

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IRWMMeshData 
{
    int partsCount { get; set; }
    Vector2[] getPartForIndex(int index);
}